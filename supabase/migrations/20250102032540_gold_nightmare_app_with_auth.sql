-- Location: supabase/migrations/20250102032540_gold_nightmare_app_with_auth.sql
-- Schema Analysis: Creating new schema from scratch for Gold Nightmare App
-- Integration Type: Complete authentication and business logic setup
-- Dependencies: auth.users (Supabase built-in)

-- 1. Create Custom Types
CREATE TYPE public.user_role AS ENUM ('admin', 'premium', 'standard');
CREATE TYPE public.license_status AS ENUM ('active', 'expired', 'suspended', 'pending');
CREATE TYPE public.analysis_type AS ENUM ('quick', 'detailed', 'comprehensive');
CREATE TYPE public.analysis_status AS ENUM ('pending', 'processing', 'completed', 'failed');

-- 2. Core Tables Creation

-- Critical intermediary table for PostgREST compatibility
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'standard'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- License key management
CREATE TABLE public.license_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key_value TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    plan_type public.user_role NOT NULL DEFAULT 'standard'::public.user_role,
    status public.license_status DEFAULT 'active'::public.license_status,
    usage_count INTEGER DEFAULT 0,
    usage_limit INTEGER DEFAULT 100,
    expires_at TIMESTAMPTZ,
    activated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Analysis storage and tracking
CREATE TABLE public.analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type public.analysis_type NOT NULL,
    status public.analysis_status DEFAULT 'pending'::public.analysis_status,
    result JSONB,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    chart_image_url TEXT,
    metadata JSONB DEFAULT '{}',
    processing_started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Analysis usage tracking for license limits
CREATE TABLE public.usage_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    license_key_id UUID REFERENCES public.license_keys(id) ON DELETE SET NULL,
    analysis_id UUID REFERENCES public.analyses(id) ON DELETE CASCADE,
    consumed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_license_keys_user_id ON public.license_keys(user_id);
CREATE INDEX idx_license_keys_key_value ON public.license_keys(key_value);
CREATE INDEX idx_license_keys_status ON public.license_keys(status);
CREATE INDEX idx_analyses_user_id ON public.analyses(user_id);
CREATE INDEX idx_analyses_status ON public.analyses(status);
CREATE INDEX idx_analyses_created_at ON public.analyses(created_at);
CREATE INDEX idx_usage_tracking_user_id ON public.usage_tracking(user_id);
CREATE INDEX idx_usage_tracking_consumed_at ON public.usage_tracking(consumed_at);

-- 4. Storage Bucket Creation
-- Private bucket for chart images - only uploader can access
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'chart-images',
    'chart-images',
    false,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg', 'image/svg+xml']
);

-- 5. Functions (MUST BE BEFORE RLS POLICIES)

-- Function to get user's current license
CREATE OR REPLACE FUNCTION public.get_user_active_license(user_uuid UUID)
RETURNS TABLE(
    license_id UUID,
    plan_type TEXT,
    usage_count INTEGER,
    usage_limit INTEGER,
    expires_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    lk.id,
    lk.plan_type::TEXT,
    lk.usage_count,
    lk.usage_limit,
    lk.expires_at
FROM public.license_keys lk
WHERE lk.user_id = user_uuid 
    AND lk.status = 'active'
    AND (lk.expires_at IS NULL OR lk.expires_at > CURRENT_TIMESTAMP)
ORDER BY lk.created_at DESC
LIMIT 1;
$$;

-- Function to check if user can perform analysis
CREATE OR REPLACE FUNCTION public.can_perform_analysis(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.license_keys lk
    WHERE lk.user_id = user_uuid
        AND lk.status = 'active'
        AND lk.usage_count < lk.usage_limit
        AND (lk.expires_at IS NULL OR lk.expires_at > CURRENT_TIMESTAMP)
);
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'standard')::public.user_role
    );
    RETURN NEW;
END;
$$;

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 6. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.license_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_tracking ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies (Following Pattern System)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for license_keys
CREATE POLICY "users_manage_own_license_keys"
ON public.license_keys
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for analyses
CREATE POLICY "users_manage_own_analyses"
ON public.analyses
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for usage_tracking
CREATE POLICY "users_manage_own_usage_tracking"
ON public.usage_tracking
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Storage RLS Policies: Private user storage pattern
CREATE POLICY "users_view_own_chart_images"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'chart-images' AND owner = auth.uid());

CREATE POLICY "users_upload_own_chart_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'chart-images' 
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_update_own_chart_images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'chart-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'chart-images' AND owner = auth.uid());

CREATE POLICY "users_delete_own_chart_images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'chart-images' AND owner = auth.uid());

-- 8. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_license_keys_updated_at
    BEFORE UPDATE ON public.license_keys
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_analyses_updated_at
    BEFORE UPDATE ON public.analyses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 9. Mock Data for Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    license1_uuid UUID := gen_random_uuid();
    license2_uuid UUID := gen_random_uuid();
    analysis1_uuid UUID := gen_random_uuid();
    analysis2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
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
         'admin@goldnightmare.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@goldnightmare.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Premium User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create license keys
    INSERT INTO public.license_keys (id, key_value, user_id, plan_type, usage_limit, expires_at) VALUES
        (license1_uuid, 'GOLD-PREMIUM-' || upper(substring(gen_random_uuid()::text, 1, 8)), admin_uuid, 'premium', 1000, CURRENT_TIMESTAMP + INTERVAL '1 year'),
        (license2_uuid, 'GOLD-STANDARD-' || upper(substring(gen_random_uuid()::text, 1, 8)), user_uuid, 'standard', 100, CURRENT_TIMESTAMP + INTERVAL '6 months');

    -- Create sample analyses
    INSERT INTO public.analyses (id, user_id, type, status, result, price, completed_at) VALUES
        (analysis1_uuid, admin_uuid, 'comprehensive', 'completed', 
         '{"prediction": "bullish", "confidence": 0.85, "target_price": 2150.00, "risk_level": "moderate"}', 29.99, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
        (analysis2_uuid, user_uuid, 'quick', 'completed',
         '{"prediction": "bearish", "confidence": 0.72, "target_price": 1950.00, "risk_level": "high"}', 9.99, CURRENT_TIMESTAMP - INTERVAL '1 hour');

    -- Create usage tracking entries
    INSERT INTO public.usage_tracking (user_id, license_key_id, analysis_id) VALUES
        (admin_uuid, license1_uuid, analysis1_uuid),
        (user_uuid, license2_uuid, analysis2_uuid);

    -- Update license usage counts
    UPDATE public.license_keys SET usage_count = 1 WHERE id = license1_uuid;
    UPDATE public.license_keys SET usage_count = 1 WHERE id = license2_uuid;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 10. Cleanup Function (for development)
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs to delete
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@goldnightmare.com';

    -- Delete in dependency order
    DELETE FROM public.usage_tracking WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.analyses WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.license_keys WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;