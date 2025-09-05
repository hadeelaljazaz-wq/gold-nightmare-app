-- Schema Analysis: Building upon existing license_keys, user_profiles, analyses, usage_tracking tables
-- Integration Type: Addition - Adding security features and activation codes
-- Dependencies: user_profiles, license_keys (existing tables)

-- Create security status enum for tracking app access
CREATE TYPE public.security_status AS ENUM ('locked', 'activated', 'suspended');

-- Create security sessions table for tracking device access
CREATE TABLE public.security_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    device_name TEXT,
    platform TEXT DEFAULT 'unknown',
    ip_address INET,
    user_agent TEXT,
    last_access TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    session_token TEXT UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create security alerts table for monitoring suspicious activity
CREATE TABLE public.security_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    alert_type TEXT NOT NULL, -- 'failed_activation', 'suspicious_login', 'unauthorized_access'
    severity TEXT DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
    message TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create activation attempts table for tracking failed attempts
CREATE TABLE public.activation_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempted_code TEXT NOT NULL,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN DEFAULT false,
    failure_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add security columns to user_profiles table
ALTER TABLE public.user_profiles 
ADD COLUMN security_status public.security_status DEFAULT 'locked',
ADD COLUMN security_score INTEGER DEFAULT 0,
ADD COLUMN failed_activation_attempts INTEGER DEFAULT 0,
ADD COLUMN last_security_check TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN two_factor_enabled BOOLEAN DEFAULT false,
ADD COLUMN biometric_enabled BOOLEAN DEFAULT false,
ADD COLUMN security_notifications BOOLEAN DEFAULT true;

-- Add security settings to license_keys table  
ALTER TABLE public.license_keys
ADD COLUMN max_devices INTEGER DEFAULT 1,
ADD COLUMN device_binding BOOLEAN DEFAULT true,
ADD COLUMN security_level TEXT DEFAULT 'standard';

-- Create indexes for performance
CREATE INDEX idx_security_sessions_user_id ON public.security_sessions(user_id);
CREATE INDEX idx_security_sessions_device_id ON public.security_sessions(device_id);
CREATE INDEX idx_security_sessions_active ON public.security_sessions(is_active);
CREATE INDEX idx_security_alerts_user_id ON public.security_alerts(user_id);
CREATE INDEX idx_security_alerts_severity ON public.security_alerts(severity);
CREATE INDEX idx_activation_attempts_user_id ON public.activation_attempts(user_id);
CREATE INDEX idx_activation_attempts_code ON public.activation_attempts(attempted_code);
CREATE INDEX idx_user_profiles_security_status ON public.user_profiles(security_status);

-- Enable RLS on new tables
ALTER TABLE public.security_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activation_attempts ENABLE ROW LEVEL SECURITY;

-- Create security functions before RLS policies
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

CREATE OR REPLACE FUNCTION public.calculate_security_score(user_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    score INTEGER := 0;
    profile_record RECORD;
BEGIN
    SELECT * INTO profile_record FROM public.user_profiles WHERE id = user_uuid;
    
    IF NOT FOUND THEN RETURN 0; END IF;
    
    -- Base score for activated users
    IF profile_record.security_status = 'activated' THEN
        score := score + 40;
    END IF;
    
    -- Two-factor authentication bonus
    IF profile_record.two_factor_enabled THEN
        score := score + 25;
    END IF;
    
    -- Biometric authentication bonus
    IF profile_record.biometric_enabled THEN
        score := score + 20;
    END IF;
    
    -- Deduct points for failed attempts
    score := score - (profile_record.failed_activation_attempts * 5);
    
    -- Recent activity bonus
    IF profile_record.last_security_check > (CURRENT_TIMESTAMP - INTERVAL '7 days') THEN
        score := score + 15;
    END IF;
    
    -- Ensure score is between 0 and 100
    RETURN GREATEST(0, LEAST(100, score));
END;
$$;

CREATE OR REPLACE FUNCTION public.validate_activation_code(code_input TEXT, user_uuid UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result JSONB := '{"valid": false, "message": "Invalid activation code"}';
    code_record RECORD;
    user_record RECORD;
BEGIN
    -- Get user record
    SELECT * INTO user_record FROM public.user_profiles WHERE id = user_uuid;
    IF NOT FOUND THEN
        RETURN '{"valid": false, "message": "User not found"}';
    END IF;
    
    -- Check if user is already activated
    IF user_record.security_status = 'activated' THEN
        RETURN '{"valid": true, "message": "User already activated", "already_active": true}';
    END IF;
    
    -- Find matching license key
    SELECT * INTO code_record 
    FROM public.license_keys 
    WHERE key_value = code_input 
    AND status = 'active'
    AND (user_id IS NULL OR user_id = user_uuid)
    LIMIT 1;
    
    IF NOT FOUND THEN
        -- Log failed attempt
        INSERT INTO public.activation_attempts (attempted_code, user_id, success, failure_reason)
        VALUES (code_input, user_uuid, false, 'Code not found');
        
        -- Increment failed attempts
        UPDATE public.user_profiles 
        SET failed_activation_attempts = failed_activation_attempts + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = user_uuid;
        
        RETURN '{"valid": false, "message": "Invalid activation code"}';
    END IF;
    
    -- Activate the license and user
    UPDATE public.license_keys
    SET user_id = user_uuid,
        activated_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = code_record.id;
    
    UPDATE public.user_profiles
    SET security_status = 'activated',
        role = code_record.plan_type,
        failed_activation_attempts = 0,
        last_security_check = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = user_uuid;
    
    -- Log successful attempt
    INSERT INTO public.activation_attempts (attempted_code, user_id, success)
    VALUES (code_input, user_uuid, true);
    
    -- Create security alert
    INSERT INTO public.security_alerts (user_id, alert_type, severity, message)
    VALUES (user_uuid, 'successful_activation', 'low', 'Account activated successfully');
    
    RETURN jsonb_build_object(
        'valid', true,
        'message', 'Activation successful',
        'plan_type', code_record.plan_type,
        'usage_limit', code_record.usage_limit
    );
END;
$$;

-- RLS Policies using Pattern 1 for core user table and Pattern 2 for others
CREATE POLICY "users_manage_own_user_profiles_extended"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

CREATE POLICY "users_manage_own_security_sessions"
ON public.security_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_view_own_security_alerts"
ON public.security_alerts
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "admins_manage_all_security_alerts"
ON public.security_alerts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "users_view_own_activation_attempts"
ON public.activation_attempts
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "admins_manage_all_activation_attempts"
ON public.activation_attempts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Create triggers for updated_at columns
CREATE TRIGGER update_security_sessions_updated_at
    BEFORE UPDATE ON public.security_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_user_profiles_updated_at_extended
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Insert 50 unique activation codes with different tiers
DO $$
DECLARE
    i INTEGER;
    code_value TEXT;
    tier_type public.user_role;
    usage_limit_val INTEGER;
BEGIN
    FOR i IN 1..50 LOOP
        -- Generate unique activation code
        code_value := 'GOLD-' || 
                      CASE 
                          WHEN i <= 10 THEN 'PREMIUM-'
                          WHEN i <= 30 THEN 'STANDARD-' 
                          ELSE 'BASIC-'
                      END ||
                      UPPER(SUBSTRING(MD5(i::text || CURRENT_TIMESTAMP::text), 1, 8));
        
        -- Set tier and limits based on code range
        IF i <= 10 THEN
            tier_type := 'premium';
            usage_limit_val := 1000;
        ELSIF i <= 30 THEN
            tier_type := 'standard';
            usage_limit_val := 500;
        ELSE
            tier_type := 'standard';
            usage_limit_val := 100;
        END IF;
        
        INSERT INTO public.license_keys (
            key_value, 
            plan_type, 
            status, 
            usage_limit,
            max_devices,
            security_level
        )
        VALUES (
            code_value,
            tier_type,
            'active',
            usage_limit_val,
            CASE WHEN tier_type = 'premium' THEN 3 ELSE 1 END,
            CASE WHEN tier_type = 'premium' THEN 'high' ELSE 'standard' END
        );
    END LOOP;
    
    RAISE NOTICE '50 activation codes generated successfully';
END $$;

-- Create sample security data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    premium_code TEXT;
BEGIN
    -- Get a premium activation code
    SELECT key_value INTO premium_code 
    FROM public.license_keys 
    WHERE plan_type = 'premium' 
    LIMIT 1;
    
    -- Insert auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'security@goldnightmare.com', crypt('SecurePass123!', gen_salt('bf', 10)), 
         now(), now(), now(),
         '{"full_name": "Security Admin", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"], "role": "admin"}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'testuser@goldnightmare.com', crypt('TestPass123!', gen_salt('bf', 10)), 
         now(), now(), now(),
         '{"full_name": "Test User"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create user profiles with security settings
    INSERT INTO public.user_profiles (
        id, email, full_name, role, is_active, 
        security_status, security_score, two_factor_enabled
    ) VALUES
        (admin_uuid, 'security@goldnightmare.com', 'Security Admin', 'admin', true,
         'activated', 100, true),
        (user_uuid, 'testuser@goldnightmare.com', 'Test User', 'standard', true,
         'locked', 0, false);

    -- Activate the premium license for admin
    UPDATE public.license_keys
    SET user_id = admin_uuid,
        activated_at = CURRENT_TIMESTAMP
    WHERE key_value = premium_code;

    -- Create security session for admin
    INSERT INTO public.security_sessions (
        user_id, device_id, device_name, platform, 
        session_token, last_access
    ) VALUES
        (admin_uuid, 'admin-device-001', 'Admin MacBook Pro', 'macOS',
         'admin-session-' || SUBSTRING(MD5(admin_uuid::text), 1, 16), CURRENT_TIMESTAMP);

    -- Create sample security alerts
    INSERT INTO public.security_alerts (user_id, alert_type, severity, message) VALUES
        (admin_uuid, 'successful_activation', 'low', 'Premium license activated successfully'),
        (user_uuid, 'failed_activation', 'medium', 'Multiple failed activation attempts detected');
        
    RAISE NOTICE 'Security system initialized with sample data';
END $$;