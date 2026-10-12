<?php

namespace Database\Seeders;

use App\Models\Exercise;
use App\Models\MuscleGroup;
use App\Models\RoutineDay;
use App\Models\RoutineDayExercise;
use App\Models\WorkoutRoutine;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. المجموعات العضلية
        $muscleGroups = [
            ['id' => 'chest', 'name_ar' => 'الصدر', 'name_en' => 'Chest', 'icon_name' => 'fitness_center', 'sort_order' => 1],
            ['id' => 'back', 'name_ar' => 'الظهر', 'name_en' => 'Back', 'icon_name' => 'sports_gymnastics', 'sort_order' => 2],
            ['id' => 'shoulders', 'name_ar' => 'الأكتاف', 'name_en' => 'Shoulders', 'icon_name' => 'accessibility_new', 'sort_order' => 3],
            ['id' => 'legs', 'name_ar' => 'الأرجل', 'name_en' => 'Legs', 'icon_name' => 'directions_walk', 'sort_order' => 4],
            ['id' => 'arms', 'name_ar' => 'الذراعين', 'name_en' => 'Arms', 'icon_name' => 'front_hand', 'sort_order' => 5],
            ['id' => 'core', 'name_ar' => 'البطن والكور', 'name_en' => 'Core & Abs', 'icon_name' => 'crop_square', 'sort_order' => 6],
        ];

        foreach ($muscleGroups as $mg) {
            MuscleGroup::updateOrCreate(['id' => $mg['id']], $mg);
        }

        // 2. مكتبة التمارين الأساسية المدمجة
        $exercises = [
            // الصدر
            ['id' => '11111111-1111-1111-1111-000000000001', 'muscle_group_id' => 'chest', 'name_ar' => 'بنش برس بار مستوي', 'name_en' => 'Flat Barbell Bench Press', 'equipment' => 'barbell'],
            ['id' => '11111111-1111-1111-1111-000000000002', 'muscle_group_id' => 'chest', 'name_ar' => 'بنش برس دمبلز علوي', 'name_en' => 'Incline Dumbbell Press', 'equipment' => 'dumbbell'],
            ['id' => '11111111-1111-1111-1111-000000000003', 'muscle_group_id' => 'chest', 'name_ar' => 'فراشة جهاز', 'name_en' => 'Pec Deck Machine Fly', 'equipment' => 'machine'],
            ['id' => '11111111-1111-1111-1111-000000000004', 'muscle_group_id' => 'chest', 'name_ar' => 'تجميع كابل سفلي للعلوي', 'name_en' => 'Low to High Cable Fly', 'equipment' => 'cable'],
            ['id' => '11111111-1111-1111-1111-000000000005', 'muscle_group_id' => 'chest', 'name_ar' => 'غطس متوازي', 'name_en' => 'Chest Dips', 'equipment' => 'bodyweight'],

            // الظهر
            ['id' => '22222222-2222-2222-2222-000000000001', 'muscle_group_id' => 'back', 'name_ar' => 'سحب عالي كابل أمامي عريض', 'name_en' => 'Wide-Grip Lat Pulldown', 'equipment' => 'cable'],
            ['id' => '22222222-2222-2222-2222-000000000002', 'muscle_group_id' => 'back', 'name_ar' => 'تجديف بار مستوي', 'name_en' => 'Bent-over Barbell Row', 'equipment' => 'barbell'],
            ['id' => '22222222-2222-2222-2222-000000000003', 'muscle_group_id' => 'back', 'name_ar' => 'سحب كابل جالس ضيق', 'name_en' => 'Seated Cable Row', 'equipment' => 'cable'],
            ['id' => '22222222-2222-2222-2222-000000000004', 'muscle_group_id' => 'back', 'name_ar' => 'ديدلفت بار كلاسيكي', 'name_en' => 'Conventional Deadlift', 'equipment' => 'barbell'],
            ['id' => '22222222-2222-2222-2222-000000000005', 'muscle_group_id' => 'back', 'name_ar' => 'تجديف دمبل فردي', 'name_en' => 'One-Arm Dumbbell Row', 'equipment' => 'dumbbell'],

            // الأكتاف
            ['id' => '33333333-3333-3333-3333-000000000001', 'muscle_group_id' => 'shoulders', 'name_ar' => 'ضغط دمبلز جالس للأكتاف', 'name_en' => 'Seated Dumbbell Shoulder Press', 'equipment' => 'dumbbell'],
            ['id' => '33333333-3333-3333-3333-000000000002', 'muscle_group_id' => 'shoulders', 'name_ar' => 'رفرفة دمبلز جانبي', 'name_en' => 'Dumbbell Lateral Raise', 'equipment' => 'dumbbell'],
            ['id' => '33333333-3333-3333-3333-000000000003', 'muscle_group_id' => 'shoulders', 'name_ar' => 'سحب كابل للوجه (كتف خلفي)', 'name_en' => 'Rope Face Pull', 'equipment' => 'cable'],
            ['id' => '33333333-3333-3333-3333-000000000004', 'muscle_group_id' => 'shoulders', 'name_ar' => 'ضغط بار عسكري واقف', 'name_en' => 'Overhead Military Press', 'equipment' => 'barbell'],

            // الأرجل
            ['id' => '44444444-4444-4444-4444-000000000001', 'muscle_group_id' => 'legs', 'name_ar' => 'سكوات بار خلفي', 'name_en' => 'Barbell Back Squat', 'equipment' => 'barbell'],
            ['id' => '44444444-4444-4444-4444-000000000002', 'muscle_group_id' => 'legs', 'name_ar' => 'جهاز ضغط الأرجل', 'name_en' => 'Leg Press Machine', 'equipment' => 'machine'],
            ['id' => '44444444-4444-4444-4444-000000000003', 'muscle_group_id' => 'legs', 'name_ar' => 'مرجحة أرجل خلفية نائم', 'name_en' => 'Lying Leg Curl', 'equipment' => 'machine'],
            ['id' => '44444444-4444-4444-4444-000000000004', 'muscle_group_id' => 'legs', 'name_ar' => 'مرجحة أرجل أمامية', 'name_en' => 'Leg Extension', 'equipment' => 'machine'],
            ['id' => '44444444-4444-4444-4444-000000000005', 'muscle_group_id' => 'legs', 'name_ar' => 'سمانة واقف', 'name_en' => 'Standing Calf Raise', 'equipment' => 'machine'],

            // الذراعين
            ['id' => '55555555-5555-5555-5555-000000000001', 'muscle_group_id' => 'arms', 'name_ar' => 'بايسبس بار متعرج واقف', 'name_en' => 'EZ-Bar Bicep Curl', 'equipment' => 'barbell'],
            ['id' => '55555555-5555-5555-5555-000000000002', 'muscle_group_id' => 'arms', 'name_ar' => 'بايسبس دمبلز شاكوش', 'name_en' => 'Dumbbell Hammer Curl', 'equipment' => 'dumbbell'],
            ['id' => '55555555-5555-5555-5555-000000000003', 'muscle_group_id' => 'arms', 'name_ar' => 'ترايسبس حبل كابل سفلي', 'name_en' => 'Tricep Rope Pushdown', 'equipment' => 'cable'],
            ['id' => '55555555-5555-5555-5555-000000000004', 'muscle_group_id' => 'arms', 'name_ar' => 'ترايسبس بار فرنسي مستوي', 'name_en' => 'Skull Crushers', 'equipment' => 'barbell'],

            // البطن والكور
            ['id' => '66666666-6666-6666-6666-000000000001', 'muscle_group_id' => 'core', 'name_ar' => 'طحن بطن كابل جالس', 'name_en' => 'Kneeling Cable Crunch', 'equipment' => 'cable'],
            ['id' => '66666666-6666-6666-6666-000000000002', 'muscle_group_id' => 'core', 'name_ar' => 'رفع أرجل معلق على العقلة', 'name_en' => 'Hanging Leg Raise', 'equipment' => 'bodyweight'],
            ['id' => '66666666-6666-6666-6666-000000000003', 'muscle_group_id' => 'core', 'name_ar' => 'بلانك', 'name_en' => 'Plank', 'equipment' => 'bodyweight'],
        ];

        foreach ($exercises as $ex) {
            Exercise::updateOrCreate(
                ['id' => $ex['id']],
                array_merge($ex, ['user_id' => null, 'is_custom' => false])
            );
        }

        // 3. جدول Push / Pull / Legs المدمج
        $pplRoutine = WorkoutRoutine::updateOrCreate(
            ['id' => '77777777-7777-7777-7777-000000000001'],
            [
                'title' => 'Push / Pull / Legs (PPL)',
                'description' => 'الجدول الكلاسيكي الأشهر عالمياً: يوم دفع (صدر وكتاف وتراي)، يوم سحب (ظهر وباي)، يوم أرجل.',
                'days_count' => 3,
                'is_active' => true,
                'is_system' => true,
                'user_id' => null,
            ]
        );

        // يوم الدفع Push
        $pushDay = RoutineDay::updateOrCreate(
            ['id' => '88888888-8888-8888-8888-000000000001'],
            ['routine_id' => $pplRoutine->id, 'day_number' => 1, 'day_name' => 'يوم الدفع (Push: صدر، كتاف، تراي)']
        );
        $pushExercises = [
            '11111111-1111-1111-1111-000000000001', // بنش برس بار
            '11111111-1111-1111-1111-000000000002', // بنش علوي
            '33333333-3333-3333-3333-000000000001', // كتف دمبل
            '33333333-3333-3333-3333-000000000002', // رفرفة جانبي
            '55555555-5555-5555-5555-000000000003', // ترايسبس حبل
        ];
        foreach ($pushExercises as $i => $exId) {
            RoutineDayExercise::updateOrCreate(
                ['routine_day_id' => $pushDay->id, 'exercise_id' => $exId],
                ['id' => (string) Str::uuid(), 'order_index' => $i + 1, 'target_sets' => 3]
            );
        }

        // يوم السحب Pull
        $pullDay = RoutineDay::updateOrCreate(
            ['id' => '88888888-8888-8888-8888-000000000002'],
            ['routine_id' => $pplRoutine->id, 'day_number' => 2, 'day_name' => 'يوم السحب (Pull: ظهر، كتف خلفي، باي)']
        );
        $pullExercises = [
            '22222222-2222-2222-2222-000000000001', // سحب عالي
            '22222222-2222-2222-2222-000000000002', // تجديف بار
            '22222222-2222-2222-2222-000000000003', // سحب كابل ضيق
            '33333333-3333-3333-3333-000000000003', // فيس بول
            '55555555-5555-5555-5555-000000000001', // باي بار
        ];
        foreach ($pullExercises as $i => $exId) {
            RoutineDayExercise::updateOrCreate(
                ['routine_day_id' => $pullDay->id, 'exercise_id' => $exId],
                ['id' => (string) Str::uuid(), 'order_index' => $i + 1, 'target_sets' => 3]
            );
        }

        // يوم الأرجل Legs
        $legsDay = RoutineDay::updateOrCreate(
            ['id' => '88888888-8888-8888-8888-000000000003'],
            ['routine_id' => $pplRoutine->id, 'day_number' => 3, 'day_name' => 'يوم الأرجل والكور (Legs & Abs)']
        );
        $legExercises = [
            '44444444-4444-4444-4444-000000000001', // سكوات
            '44444444-4444-4444-4444-000000000002', // جهاز ضغط
            '44444444-4444-4444-4444-000000000003', // مرجحة خلفي
            '44444444-4444-4444-4444-000000000005', // سمانة
            '66666666-6666-6666-6666-000000000001', // طحن بطن كابل
        ];
        foreach ($legExercises as $i => $exId) {
            RoutineDayExercise::updateOrCreate(
                ['routine_day_id' => $legsDay->id, 'exercise_id' => $exId],
                ['id' => (string) Str::uuid(), 'order_index' => $i + 1, 'target_sets' => 3]
            );
        }
    }
}
