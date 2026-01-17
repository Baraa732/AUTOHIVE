<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            // Add unique constraint to prevent multiple reviews per booking
            $table->unique(['booking_id']);
            
            // Add additional rating fields for more detailed feedback
            $table->integer('cleanliness_rating')->unsigned()->nullable()->after('rating');
            $table->integer('location_rating')->unsigned()->nullable()->after('cleanliness_rating');
            $table->integer('value_rating')->unsigned()->nullable()->after('location_rating');
            $table->integer('communication_rating')->unsigned()->nullable()->after('value_rating');
            
            // Add indexes for performance
            $table->index('apartment_id');
            $table->index('user_id');
        });
        
        // Add average rating column to apartments table
        Schema::table('apartments', function (Blueprint $table) {
            $table->decimal('average_rating', 3, 2)->default(0)->after('status');
            $table->integer('total_ratings')->default(0)->after('average_rating');
        });
    }

    public function down(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->dropUnique(['booking_id']);
            $table->dropColumn(['cleanliness_rating', 'location_rating', 'value_rating', 'communication_rating']);
            $table->dropIndex(['apartment_id']);
            $table->dropIndex(['user_id']);
        });
        
        Schema::table('apartments', function (Blueprint $table) {
            $table->dropColumn(['average_rating', 'total_ratings']);
        });
    }
};
