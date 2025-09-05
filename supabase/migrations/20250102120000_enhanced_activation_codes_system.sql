-- Location: supabase/migrations/20250102120000_enhanced_activation_codes_system.sql
-- Schema Analysis: license_keys table exists with plan_type, status, expires_at columns
-- Integration Type: enhancement - adding 14-day expiration and fixed admin code functionality
-- Dependencies: existing license_keys, user_profiles tables

-- 1. Add new columns to existing license_keys table for enhanced functionality
ALTER TABLE public.license_keys
ADD COLUMN IF NOT EXISTS max_devices INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS security_level TEXT DEFAULT 'standard',
ADD COLUMN IF NOT EXISTS is_fixed_admin BOOLEAN DEFAULT false;

-- 2. Create index for new columns
CREATE INDEX IF NOT EXISTS idx_license_keys_max_devices ON public.license_keys(max_devices);
CREATE INDEX IF NOT EXISTS idx_license_keys_security_level ON public.license_keys(security_level);
CREATE INDEX IF NOT EXISTS idx_license_keys_is_fixed_admin ON public.license_keys(is_fixed_admin);

-- 3. Enhanced function to generate activation codes with 14-day expiration
CREATE OR REPLACE FUNCTION public.generate_activation_codes_batch(
    code_count INTEGER,
    plan_type_param public.user_role DEFAULT 'standard'::public.user_role,
    usage_limit_param INTEGER DEFAULT 100
)
RETURNS TABLE(generated_codes TEXT[])
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    generated_codes_array TEXT[] := '{}';
    i INTEGER := 1;
    code_value TEXT;
    random_suffix TEXT;
BEGIN
    WHILE i <= code_count LOOP
        -- Generate random 8-character suffix using timestamp and random
        random_suffix := UPPER(
            SUBSTRING(
                MD5(EXTRACT(EPOCH FROM NOW())::TEXT || RANDOM()::TEXT || i::TEXT),
                1, 8
            )
        );
        
        code_value := 'GOLD-' || UPPER(plan_type_param::TEXT) || '-' || random_suffix;
        
        -- Insert activation code with 14-day expiration
        INSERT INTO public.license_keys (
            key_value,
            plan_type,
            status,
            usage_limit,
            expires_at,
            max_devices,
            security_level,
            is_fixed_admin
        ) VALUES (
            code_value,
            plan_type_param,
            'active'::public.license_status,
            usage_limit_param,
            NOW() + INTERVAL '14 days', -- 14-day expiration
            CASE 
                WHEN plan_type_param = 'premium'::public.user_role THEN 3
                WHEN plan_type_param = 'admin'::public.user_role THEN 5
                ELSE 1
            END,
            CASE 
                WHEN plan_type_param = 'premium'::public.user_role THEN 'high'
                WHEN plan_type_param = 'admin'::public.user_role THEN 'maximum'
                ELSE 'standard'
            END,
            plan_type_param = 'admin'::public.user_role
        );
        
        generated_codes_array := array_append(generated_codes_array, code_value);
        i := i + 1;
    END LOOP;
    
    RETURN QUERY SELECT generated_codes_array;
END;
$func$;

-- 4. Function to create fixed admin code with permanent access
CREATE OR REPLACE FUNCTION public.create_fixed_admin_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    admin_code TEXT;
    random_suffix TEXT;
BEGIN
    -- Generate unique admin code
    random_suffix := UPPER(
        SUBSTRING(
            MD5('ADMIN-' || EXTRACT(EPOCH FROM NOW())::TEXT || RANDOM()::TEXT),
            1, 8
        )
    );
    
    admin_code := 'GOLD-ADMIN-' || random_suffix;
    
    -- Insert fixed admin code with no expiration
    INSERT INTO public.license_keys (
        key_value,
        plan_type,
        status,
        usage_limit,
        expires_at,
        max_devices,
        security_level,
        is_fixed_admin
    ) VALUES (
        admin_code,
        'admin'::public.user_role,
        'active'::public.license_status,
        9999, -- High limit for admin
        NULL, -- No expiration for admin
        10, -- Multiple device access
        'maximum',
        true
    );
    
    RETURN admin_code;
END;
$func$;

-- 5. Enhanced function to check license expiration
CREATE OR REPLACE FUNCTION public.check_license_expiration()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    -- Update expired licenses (exclude admin codes)
    UPDATE public.license_keys
    SET status = 'expired'::public.license_status,
        updated_at = NOW()
    WHERE expires_at IS NOT NULL 
      AND expires_at < NOW() 
      AND status = 'active'::public.license_status
      AND is_fixed_admin = false;
      
    -- Log expiration check
    RAISE NOTICE 'License expiration check completed at %', NOW();
END;
$func$;

-- 6. Function to get activation code statistics for admin
CREATE OR REPLACE FUNCTION public.get_activation_code_statistics()
RETURNS TABLE(
    total_codes INTEGER,
    active_codes INTEGER,
    expired_codes INTEGER,
    used_codes INTEGER,
    unused_codes INTEGER,
    admin_codes INTEGER,
    codes_expiring_soon INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT
    COUNT(*)::INTEGER as total_codes,
    COUNT(*) FILTER (WHERE status = 'active'::public.license_status)::INTEGER as active_codes,
    COUNT(*) FILTER (WHERE status = 'expired'::public.license_status)::INTEGER as expired_codes,
    COUNT(*) FILTER (WHERE user_id IS NOT NULL)::INTEGER as used_codes,
    COUNT(*) FILTER (WHERE user_id IS NULL AND status = 'active'::public.license_status)::INTEGER as unused_codes,
    COUNT(*) FILTER (WHERE is_fixed_admin = true)::INTEGER as admin_codes,
    COUNT(*) FILTER (WHERE expires_at IS NOT NULL AND expires_at < NOW() + INTERVAL '3 days' AND status = 'active'::public.license_status)::INTEGER as codes_expiring_soon
FROM public.license_keys;
$func$;

-- 7. Generate initial 50 standard activation codes with 14-day expiration
DO $batch$
BEGIN
    -- Generate 50 standard codes
    PERFORM public.generate_activation_codes_batch(50, 'standard'::public.user_role, 100);
    
    -- Create one fixed admin code
    PERFORM public.create_fixed_admin_code();
    
    RAISE NOTICE 'Generated 50 standard activation codes with 14-day expiration and 1 fixed admin code';
END $batch$;

-- 8. Create a scheduled function to periodically check license expiration
-- Note: PostgreSQL doesn't support BEFORE SELECT triggers
-- Instead, we rely on application-level calls to check_license_expiration()
-- This function can be called by the application or via pg_cron extension if available

CREATE OR REPLACE FUNCTION public.schedule_license_expiration_check()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $schedule_func$
BEGIN
    -- This function can be called periodically by the application
    -- or scheduled using pg_cron extension if available
    PERFORM public.check_license_expiration();
    
    RAISE NOTICE 'Scheduled license expiration check completed at %', NOW();
END;
$schedule_func$;

-- 9. Create a view for easy access to license statistics
CREATE OR REPLACE VIEW public.license_statistics AS
SELECT 
    COUNT(*)::INTEGER as total_codes,
    COUNT(*) FILTER (WHERE status = 'active'::public.license_status)::INTEGER as active_codes,
    COUNT(*) FILTER (WHERE status = 'expired'::public.license_status)::INTEGER as expired_codes,
    COUNT(*) FILTER (WHERE user_id IS NOT NULL)::INTEGER as used_codes,
    COUNT(*) FILTER (WHERE user_id IS NULL AND status = 'active'::public.license_status)::INTEGER as unused_codes,
    COUNT(*) FILTER (WHERE is_fixed_admin = true)::INTEGER as admin_codes,
    COUNT(*) FILTER (WHERE expires_at IS NOT NULL AND expires_at < NOW() + INTERVAL '3 days' AND status = 'active'::public.license_status)::INTEGER as codes_expiring_soon
FROM public.license_keys;

-- 10. Grant necessary permissions
GRANT SELECT ON public.license_statistics TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_activation_code_statistics() TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_license_expiration() TO authenticated;
GRANT EXECUTE ON FUNCTION public.schedule_license_expiration_check() TO authenticated;