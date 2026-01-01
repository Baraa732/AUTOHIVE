<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rental_applications', function (Blueprint $table) {
            $table->enum('status', ['pending', 'approved', 'rejected', 'modified-pending', 'modified-approved'])->change();
            $table->string('previous_status')->nullable()->after('status');
            $table->json('previous_data')->nullable()->after('previous_status');
            $table->json('current_data')->nullable()->after('previous_data');
            $table->text('modification_reason')->nullable()->after('current_data');
            $table->timestamp('modification_submitted_at')->nullable()->after('modification_reason');
        });
    }

    public function down(): void
    {
        Schema::table('rental_applications', function (Blueprint $table) {
            $table->dropColumn([
                'previous_status',
                'previous_data',
                'current_data',
                'modification_reason',
                'modification_submitted_at',
            ]);
        });
    }
};
