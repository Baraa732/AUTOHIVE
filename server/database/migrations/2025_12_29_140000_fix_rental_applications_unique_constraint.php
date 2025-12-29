<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // This migration is no longer needed as the constraint is created correctly
        // in the create_rental_applications_table migration with the short name
    }

    public function down(): void
    {
        try {
            DB::statement('ALTER TABLE `rental_applications` DROP INDEX `rental_apps_unique`');
        } catch (\Exception $e) {
            // Index might not exist
        }
    }
};
