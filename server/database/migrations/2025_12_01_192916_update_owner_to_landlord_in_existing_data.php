<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Skip this migration as changes are already applied
        return;
    }

    public function down()
    {
        // Rename landlord_id back to owner_id
        Schema::table('apartments', function (Blueprint $table) {
            $table->renameColumn('landlord_id', 'owner_id');
        });
        
        // Update landlord records back to owner
        DB::table('users')->where('role', 'landlord')->update(['role' => 'owner']);
        
        // Revert role enum
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('tenant', 'owner', 'admin') DEFAULT 'tenant'");
    }
};