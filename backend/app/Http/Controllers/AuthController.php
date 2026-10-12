<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'phone' => 'required|string|max:25|unique:users,phone',
            'email' => 'nullable|email|unique:users,email',
            'password' => 'required|string|min:6',
        ], [
            'phone.required' => 'رقم الهاتف مطلوب لتسجيل الحساب',
            'phone.unique' => 'رقم الهاتف هذا مسجل بالفعل',
            'email.email' => 'يرجى إدخال بريد إلكتروني صالح أو تركه فارغاً',
            'email.unique' => 'البريد الإلكتروني هذا مسجل بالفعل',
            'password.min' => 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'phone' => $validated['phone'],
            'email' => !empty($validated['email']) ? $validated['email'] : null,
            'password' => Hash::make($validated['password']),
        ]);

        $token = $user->createToken('ironlog_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'تم إنشاء الحساب بنجاح',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'email' => $user->email,
            ],
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'nullable|string',
            'email' => 'nullable|string',
            'identifier' => 'nullable|string',
            'password' => 'required|string',
        ]);

        $identifier = $validated['phone'] ?? $validated['identifier'] ?? $validated['email'] ?? null;

        if (!$identifier) {
            return response()->json([
                'status' => 'error',
                'message' => 'يرجى إدخال رقم الهاتف المسجل للدخول',
            ], 422);
        }

        $cleanPhone = ltrim(ltrim($identifier, '+'), '0');

        $user = User::where('phone', $identifier)
                    ->orWhere('email', $identifier)
                    ->orWhere('phone', 'like', '%' . $cleanPhone)
                    ->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'رقم الهاتف أو كلمة المرور غير صحيحة',
            ], 401);
        }

        $token = $user->createToken('ironlog_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل الدخول بنجاح',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'email' => $user->email,
            ],
            'token' => $token,
        ]);
    }

    public function resetPassword(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string|min:6',
        ], [
            'phone.required' => 'رقم الهاتف مطلوب للتحقق من الحساب',
            'password.required' => 'كلمة المرور الجديدة مطلوبة',
            'password.min' => 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
        ]);

        $phone = $validated['phone'];
        $cleanPhone = ltrim(ltrim($phone, '+'), '0');

        $user = User::where('phone', $phone)
                    ->orWhere('phone', 'like', '%' . $cleanPhone)
                    ->first();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'لم يتم العثور على حساب مسجل برقم الهاتف هذا',
            ], 404);
        }

        $user->password = Hash::make($validated['password']);
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'تم التحقق من البصمة وإعادة تعيين كلمة المرور بنجاح!',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
            ],
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'user' => $request->user(),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل الخروج بنجاح',
        ]);
    }
}