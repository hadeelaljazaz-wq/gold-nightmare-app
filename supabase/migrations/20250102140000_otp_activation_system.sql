-- Location: supabase/migrations/20250102140000_otp_activation_system.sql
-- Schema Analysis: Existing user_profiles table with email column for OTP verification
-- Integration Type: Addition - Adding OTP verification system
-- Dependencies: user_profiles table (existing)

-- Create OTP verification codes table for email activation
CREATE TABLE public.otp_verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    purpose TEXT NOT NULL CHECK (purpose IN ('activation', 'password_reset', 'email_change')),
    expires_at TIMESTAMPTZ NOT NULL,
    is_used BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for efficient OTP lookup and cleanup
CREATE INDEX idx_otp_email_purpose ON public.otp_verification_codes(email, purpose);
CREATE INDEX idx_otp_expires_at ON public.otp_verification_codes(expires_at);
CREATE INDEX idx_otp_code ON public.otp_verification_codes(otp_code);

-- Enable RLS for OTP table
ALTER TABLE public.otp_verification_codes ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own OTP codes for verification
CREATE POLICY "users_can_view_own_otp_codes"
ON public.otp_verification_codes
FOR SELECT
TO authenticated
USING (email = (SELECT email FROM auth.users WHERE id = auth.uid()));

-- Allow anonymous users to verify OTP codes (for activation flow)
CREATE POLICY "anonymous_can_verify_otp_codes"
ON public.otp_verification_codes
FOR SELECT
TO anon
USING (NOT is_used AND expires_at > now());

-- Functions for OTP management
CREATE OR REPLACE FUNCTION public.generate_otp_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Generate 6-digit OTP code
    RETURN lpad((random() * 999999)::integer::text, 6, '0');
END;
$$;

CREATE OR REPLACE FUNCTION public.create_otp_verification(
    user_email TEXT,
    verification_purpose TEXT DEFAULT 'activation'
)
RETURNS TABLE(otp_code TEXT, expires_at TIMESTAMPTZ)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_otp TEXT;
    expiry_time TIMESTAMPTZ;
BEGIN
    -- Generate OTP and set expiry (5 minutes from now)
    new_otp := public.generate_otp_code();
    expiry_time := now() + interval '5 minutes';
    
    -- Deactivate any existing OTP codes for this email/purpose
    UPDATE public.otp_verification_codes 
    SET is_used = true 
    WHERE email = user_email AND purpose = verification_purpose AND NOT is_used;
    
    -- Create new OTP code
    INSERT INTO public.otp_verification_codes (email, otp_code, purpose, expires_at)
    VALUES (user_email, new_otp, verification_purpose, expiry_time);
    
    -- Return OTP code and expiry time
    RETURN QUERY SELECT new_otp, expiry_time;
END;
$$;

CREATE OR REPLACE FUNCTION public.verify_otp_code(
    user_email TEXT,
    provided_otp TEXT,
    verification_purpose TEXT DEFAULT 'activation'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    otp_record RECORD;
    is_valid BOOLEAN := false;
BEGIN
    -- Find the OTP record
    SELECT * INTO otp_record
    FROM public.otp_verification_codes
    WHERE email = user_email 
    AND otp_code = provided_otp 
    AND purpose = verification_purpose
    AND NOT is_used
    AND expires_at > now()
    LIMIT 1;
    
    -- Check if OTP is valid
    IF FOUND THEN
        -- Mark OTP as used
        UPDATE public.otp_verification_codes
        SET is_used = true
        WHERE id = otp_record.id;
        
        is_valid := true;
    END IF;
    
    RETURN is_valid;
END;
$$;

-- Cleanup expired OTP codes function
CREATE OR REPLACE FUNCTION public.cleanup_expired_otp_codes()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete expired OTP codes older than 1 hour
    DELETE FROM public.otp_verification_codes
    WHERE expires_at < now() - interval '1 hour';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;

-- Create function to activate user account with OTP
CREATE OR REPLACE FUNCTION public.activate_user_account(
    user_email TEXT,
    provided_otp TEXT
)
RETURNS TABLE(success BOOLEAN, message TEXT, user_id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
    is_otp_valid BOOLEAN;
    new_user_id UUID;
BEGIN
    -- Verify OTP code first
    SELECT public.verify_otp_code(user_email, provided_otp, 'activation') INTO is_otp_valid;
    
    IF NOT is_otp_valid THEN
        RETURN QUERY SELECT false, 'Invalid or expired OTP code', NULL::UUID;
        RETURN;
    END IF;
    
    -- Check if user already exists in user_profiles
    SELECT * INTO user_record FROM public.user_profiles WHERE email = user_email LIMIT 1;
    
    IF FOUND THEN
        -- Update existing user as active
        UPDATE public.user_profiles 
        SET is_active = true, updated_at = now()
        WHERE id = user_record.id;
        
        RETURN QUERY SELECT true, 'Account activated successfully', user_record.id;
    ELSE
        -- Create new user profile (this would typically be done after Supabase auth signup)
        new_user_id := gen_random_uuid();
        
        INSERT INTO public.user_profiles (id, email, full_name, is_active)
        VALUES (new_user_id, user_email, split_part(user_email, '@', 1), true);
        
        RETURN QUERY SELECT true, 'Account created and activated successfully', new_user_id;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Account activation failed: ' || SQLERRM, NULL::UUID;
END;
$$;

-- Mock data for testing OTP system
DO $$
DECLARE
    test_otp TEXT;
    test_expiry TIMESTAMPTZ;
BEGIN
    -- Create a test OTP for demo purposes
    SELECT otp_code, expires_at INTO test_otp, test_expiry
    FROM public.create_otp_verification('test@goldnightmare.com', 'activation');
    
    -- Log the test OTP for development purposes
    RAISE NOTICE 'Test OTP created: % (expires at: %)', test_otp, test_expiry;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data creation failed: %', SQLERRM;
END $$;