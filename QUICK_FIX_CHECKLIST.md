# 🚀 Quick Fix Checklist - Domain Not Allowed Error

## ✅ What I Just Fixed in Your Code

I updated **3 locations** in `auth_cubit.dart` to use proper `ActionCodeSettings`:

1. ✅ `signup()` method - Line ~94
2. ✅ `resendVerificationEmail()` method - Line ~224  
3. ✅ `resendEmailOtp()` method - Line ~342

All now use:
```dart
ActionCodeSettings(
  url: 'https://iconnect-qatar-5513.firebaseapp.com/__/auth/action',
  handleCodeInApp: false,
  androidPackageName: 'com.iconnect.application',
  androidInstallApp: false,
  androidMinimumVersion: '21',
)
```

## 🔥 Firebase Console Setup (DO THIS NOW)

### 1️⃣ Enable Email/Password Authentication
```
Firebase Console → Authentication → Sign-in method → Email/Password → Enable → Save
```

### 2️⃣ Add Authorized Domains
```
Firebase Console → Authentication → Settings → Authorized domains
```

**Add these domains:**
- ✅ `iconnect-qatar-5513.firebaseapp.com`
- ✅ `localhost`

### 3️⃣ Verify Your Configuration
- Project ID: `iconnect-qatar-5513` ✅
- Package name: `com.iconnect.application` ✅
- Auth domain: `iconnect-qatar-5513.firebaseapp.com` ✅

## 🛠️ After Firebase Console Changes

Run these commands:
```bash
flutter clean
flutter pub get
flutter run
```

## 🧪 Test It

1. **Sign up** with a real email
2. **Check** your email inbox (and spam!)
3. **Click** the verification link
4. **Return** to app and click "I've Verified"
5. **Success!** You should be logged in

## 🚨 Still Getting Error?

### Double-check Firebase Console:
1. Go to: https://console.firebase.google.com/
2. Select: `iconnect-qatar-5513`
3. Authentication → Sign-in method → Email/Password should be **ENABLED**
4. Authentication → Settings → Authorized domains should include:
   - `iconnect-qatar-5513.firebaseapp.com`
   - `localhost`

### Check the exact error message:
- Look at your app console/logs
- Note the exact error code (e.g., `auth/unauthorized-domain`)
- Share it if you need more help

## 📧 Email Not Arriving?

1. **Check spam folder** first!
2. Wait 2-3 minutes (emails can be delayed)
3. Try with a different email provider (Gmail, Outlook, etc.)
4. Click "Resend" after 60 seconds

## 🎯 Why This Happens

The error occurs because:
1. Firebase sends an email with a verification link
2. The link uses a domain (e.g., `iconnect-qatar-5513.firebaseapp.com`)
3. Firebase checks if that domain is authorized
4. If not in the list → **Error: Domain not allowed**

## 💡 Quick Debug

Add this temporarily to see what's happening:

```dart
// In auth_cubit.dart, in the signup method's catch block:
} catch (e) {
  print('SIGNUP ERROR: $e'); // Add this line
  emit(AuthError(e.toString()));
}
```

This will print the exact error to your console.

## ✅ Final Checklist

Before testing:
- [ ] Code updated (already done ✅)
- [ ] Firebase Console: Email/Password enabled
- [ ] Firebase Console: Domains authorized
- [ ] App cleaned and rebuilt
- [ ] Using real email address
- [ ] Internet connection working

## 🎉 Success Indicators

You'll know it's working when:
- ✅ No error after clicking "Sign Up"
- ✅ Verification screen appears
- ✅ Email arrives in inbox
- ✅ Verification link works
- ✅ "I've Verified" button logs you in

---

**Your Firebase Domain:** `iconnect-qatar-5513.firebaseapp.com`  
**Your Package Name:** `com.iconnect.application`  
**Your Project ID:** `iconnect-qatar-5513`

Need more help? Check `DOMAIN_ERROR_TROUBLESHOOTING.md` for detailed solutions!
