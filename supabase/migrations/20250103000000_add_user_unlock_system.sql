-- Location: supabase/migrations/20250103000000_add_user_unlock_system.sql
-- Schema Analysis: Extending existing user_profiles with is_unlocked field
-- Integration Type: addition/extension
-- Dependencies: user_profiles (existing table)

-- Add is_unlocked column to existing user_profiles table
ALTER TABLE public.user_profiles
ADD COLUMN is_unlocked BOOLEAN DEFAULT false;

-- Add index for efficient queries on is_unlocked status
CREATE INDEX idx_user_profiles_is_unlocked ON public.user_profiles(is_unlocked);

-- Admin management functions for user unlock status
CREATE OR REPLACE FUNCTION public.get_all_users_for_admin()
RETURNS TABLE(
    id UUID,
    email TEXT,
    full_name TEXT,
    role TEXT,
    is_active BOOLEAN,
    is_unlocked BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    last_sign_in_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    up.id,
    up.email,
    up.full_name,
    up.role::TEXT,
    up.is_active,
    up.is_unlocked,
    up.created_at,
    up.updated_at,
    au.last_sign_in_at
FROM public.user_profiles up
LEFT JOIN auth.users au ON up.id = au.id
ORDER BY up.created_at DESC;
$$;

-- Function to update user unlock status (admin only)
CREATE OR REPLACE FUNCTION public.update_user_unlock_status(
    target_user_id UUID,
    unlock_status BOOLEAN
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    admin_role TEXT;
BEGIN
    -- Check if current user is admin
    SELECT role::TEXT INTO admin_role
    FROM public.user_profiles
    WHERE id = auth.uid();
    
    IF admin_role != 'admin' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Update the user's unlock status
    UPDATE public.user_profiles
    SET is_unlocked = unlock_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = target_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User not found with ID: %', target_user_id;
    END IF;
    
    RETURN TRUE;
END;
$$;

-- Function to check if user is unlocked and active
CREATE OR REPLACE FUNCTION public.is_user_unlocked_and_active()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid()
    AND up.is_active = true
    AND up.is_unlocked = true
);
$$;

-- Add admin policy for user management (using Pattern 6 Option A - auth metadata)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
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
);
$$;

-- Admin can view all user profiles
CREATE POLICY "admin_can_view_all_user_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (
    id = auth.uid() OR public.is_admin_from_auth()
);

-- Admin can update user unlock status
CREATE POLICY "admin_can_update_user_unlock_status"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (
    id = auth.uid() OR public.is_admin_from_auth()
)
WITH CHECK (
    id = auth.uid() OR public.is_admin_from_auth()
);

-- Update existing users to be unlocked by default for admin
DO $$
DECLARE
    admin_user_id UUID;
BEGIN
    -- Find admin user and unlock them
    SELECT id INTO admin_user_id
    FROM public.user_profiles
    WHERE role = 'admin'::public.user_role
    LIMIT 1;
    
    IF admin_user_id IS NOT NULL THEN
        UPDATE public.user_profiles
        SET is_unlocked = true
        WHERE id = admin_user_id;
    END IF;
END $$;

-- Grant necessary permissions to functions
GRANT EXECUTE ON FUNCTION public.get_all_users_for_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_user_unlock_status(UUID, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_user_unlocked_and_active() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_from_auth() TO authenticated;