<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Update existing users to have UUID format IDs
        $users = DB::table('users')->get();
        foreach ($users as $user) {
            $uuid = \Str::uuid();
            DB::table('users')->where('id', $user->id)->update(['id' => $uuid]);
            
            // Update related tables
            DB::table('apartments')->where('landlord_id', $user->id)->update(['landlord_id' => $uuid]);
            DB::table('bookings')->where('tenant_id', $user->id)->update(['tenant_id' => $uuid]);
            DB::table('reviews')->where('tenant_id', $user->id)->update(['tenant_id' => $uuid]);
            DB::table('favorites')->where('tenant_id', $user->id)->update(['tenant_id' => $uuid]);
            DB::table('notifications')->where('user_id', $user->id)->update(['user_id' => $uuid]);
            DB::table('activities')->where('admin_id', $user->id)->update(['admin_id' => $uuid]);
        }
    }

    public function down()
    {
        // Cannot reverse UUID changes
    }
};