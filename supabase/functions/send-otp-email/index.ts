import { serve } from "https://deno.land/std@0.192.0/http/server.ts";

serve(async (req) => {
  // ✅ CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*", // DO NOT CHANGE THIS
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "*" // DO NOT CHANGE THIS
      }
    });
  }

  try {
    const { email, purpose = 'activation' } = await req.json();
    
    if (!email) {
      throw new Error('Email is required');
    }

    // Generate 6-digit OTP
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Set expiry time (5 minutes from now)
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

    // Store OTP in database using Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    const dbResponse = await fetch(`${supabaseUrl}/rest/v1/otp_verification_codes`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify({
        email: email,
        otp_code: otpCode,
        purpose: purpose,
        expires_at: expiresAt,
        is_used: false
      })
    });

    if (!dbResponse.ok) {
      throw new Error(`Failed to store OTP: ${dbResponse.statusText}`);
    }

    // Send email via Resend
    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'onboarding@resend.dev',
        to: [email],
        subject: purpose === 'activation' ? 'رمز التفعيل - Gold Nightmare App' : 'رمز إعادة تعيين كلمة المرور',
        html: `
          <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
              <h1 style="margin: 0; font-size: 28px;">Gold Nightmare App</h1>
              <p style="margin: 10px 0 0; font-size: 16px; opacity: 0.9;">
                ${purpose === 'activation' ? 'تفعيل الحساب' : 'إعادة تعيين كلمة المرور'}
              </p>
            </div>
            
            <div style="background: white; padding: 40px; border-radius: 0 0 10px 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
              <h2 style="color: #1e3a8a; margin-bottom: 20px;">
                ${purpose === 'activation' ? 'مرحباً بك!' : 'إعادة تعيين كلمة المرور'}
              </h2>
              
              <p style="color: #4b5563; line-height: 1.6; margin-bottom: 30px;">
                ${purpose === 'activation' 
                  ? 'يرجى استخدام رمز التفعيل التالي لتفعيل حسابك:'
                  : 'يرجى استخدام الرمز التالي لإعادة تعيين كلمة المرور:'}
              </p>
              
              <div style="background: #f3f4f6; border: 2px dashed #d1d5db; padding: 20px; text-align: center; border-radius: 8px; margin: 30px 0;">
                <span style="font-size: 32px; font-weight: bold; color: #1e3a8a; letter-spacing: 5px; font-family: monospace;">
                  ${otpCode}
                </span>
              </div>
              
              <div style="background: #fef3c7; border-right: 4px solid #f59e0b; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <p style="margin: 0; color: #92400e; font-size: 14px;">
                  <strong>⚠️ تنبيه:</strong> هذا الرمز صالح لمدة 5 دقائق فقط
                </p>
              </div>
              
              <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
                <p style="color: #6b7280; font-size: 12px; margin: 0; text-align: center;">
                  إذا لم تطلب هذا الرمز، يرجى تجاهل هذه الرسالة
                </p>
              </div>
            </div>
          </div>
        `
      })
    });

    if (!emailResponse.ok) {
      throw new Error(`Failed to send email: ${emailResponse.statusText}`);
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'تم إرسال رمز التفعيل بنجاح',
      expires_at: expiresAt
    }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // DO NOT CHANGE THIS
      }
    });

  } catch (error) {
    return new Response(JSON.stringify({
      success: false,
      error: error.message
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // DO NOT CHANGE THIS
      }
    });
  }
});