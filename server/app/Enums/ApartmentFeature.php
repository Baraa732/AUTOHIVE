<?php

namespace App\Enums;

enum ApartmentFeature: string
{
    case WIFI = 'wifi';
    case AIR_CONDITIONING = 'air_conditioning';
    case HEATING = 'heating';
    case KITCHEN = 'kitchen';
    case WASHING_MACHINE = 'washing_machine';
    case PARKING = 'parking';
    case BALCONY = 'balcony';
    case ELEVATOR = 'elevator';
    case SECURITY = 'security';
    case FURNISHED = 'furnished';
    case PET_FRIENDLY = 'pet_friendly';
    case SWIMMING_POOL = 'swimming_pool';
    case GYM = 'gym';
    case GARDEN = 'garden';
    case TERRACE = 'terrace';

    public function label(): string
    {
        return match($this) {
            self::WIFI => 'WiFi',
            self::AIR_CONDITIONING => 'Air Conditioning',
            self::HEATING => 'Heating',
            self::KITCHEN => 'Kitchen',
            self::WASHING_MACHINE => 'Washing Machine',
            self::PARKING => 'Parking',
            self::BALCONY => 'Balcony',
            self::ELEVATOR => 'Elevator',
            self::SECURITY => 'Security',
            self::FURNISHED => 'Furnished',
            self::PET_FRIENDLY => 'Pet Friendly',
            self::SWIMMING_POOL => 'Swimming Pool',
            self::GYM => 'Gym',
            self::GARDEN => 'Garden',
            self::TERRACE => 'Terrace',
        };
    }

    public static function all(): array
    {
        return array_map(fn($case) => [
            'value' => $case->value,
            'label' => $case->label()
        ], self::cases());
    }
}