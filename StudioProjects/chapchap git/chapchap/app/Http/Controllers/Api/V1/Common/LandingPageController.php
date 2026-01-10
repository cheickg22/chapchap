<?php

namespace App\Http\Controllers\Api\V1\Common;

use App\Http\Controllers\Web\BaseController;
use Illuminate\Http\Request;
use App\Models\Admin\LandingHome;
use App\Models\Admin\LandingHeader;
use App\Models\Admin\LandingDriver;
use App\Models\Admin\LandingUser;
use App\Models\Admin\LandingContact;
use App\Models\Admin\LandingQuickLink;
use App\Models\Admin\LandingAbouts;
use App\Models\Languages;
use Illuminate\Support\Facades\Storage;

class LandingPageController extends BaseController
{
    /**
     * Récupérer toutes les données de la landing page
     * Utilisé par la nouvelle landing page Vue.js
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        // Déterminer la locale
        $defaultLocale = Languages::where('default_status', true)->value('code') ?? 'en';
        $locale = $request->input('locale', $defaultLocale);

        // Récupérer toutes les sections
        $home = LandingHome::where('locale', $locale)->first() 
            ?? LandingHome::where('locale', 'en')->first();
            
        $header = LandingHeader::where('locale', $locale)->first()
            ?? LandingHeader::where('locale', 'en')->first();
            
        $driver = LandingDriver::where('locale', $locale)->first()
            ?? LandingDriver::where('locale', 'en')->first();
            
        $user = LandingUser::where('locale', $locale)->first()
            ?? LandingUser::where('locale', 'en')->first();
            
        $contact = LandingContact::where('locale', $locale)->first()
            ?? LandingContact::where('locale', 'en')->first();
            
        $quickLinks = LandingQuickLink::where('locale', $locale)->first()
            ?? LandingQuickLink::where('locale', 'en')->first();
            
        $about = LandingAbouts::where('locale', $locale)->first()
            ?? LandingAbouts::where('locale', 'en')->first();

        return $this->respondSuccess([
            'locale' => $locale,
            'hero' => $this->formatHeroSection($home, $header),
            'services' => $this->formatServicesSection($home),
            'features' => $this->formatFeaturesSection($home),
            'driver' => $this->formatDriverSection($driver),
            'user' => $this->formatUserSection($user),
            'about' => $this->formatAboutSection($about),
            'contact' => $this->formatContactSection($contact),
            'downloads' => $this->formatDownloadsSection($home),
            'footer' => $this->formatFooterSection($quickLinks, $contact),
        ]);
    }

    /**
     * Formater la section Hero
     */
    private function formatHeroSection($home, $header)
    {
        if (!$home && !$header) {
            return null;
        }

        return [
            'title' => $home->hero_title ?? $header->title ?? 'Transport et Livraison Rapide au Mali',
            'subtitle' => $header->subtitle ?? 'Taxi, Livraison, MoovMoney - Tout en un',
            'cta_primary' => $header->cta_primary ?? 'Commander maintenant',
            'cta_secondary' => $header->cta_secondary ?? 'Devenir chauffeur',
            'image' => $header->image ? $this->getImageUrl($header->image) : null,
            'stats' => [
                'rides' => '10K+',
                'drivers' => '500+',
                'cities' => '5',
            ],
        ];
    }

    /**
     * Formater la section Services
     */
    private function formatServicesSection($home)
    {
        if (!$home) {
            return $this->getDefaultServices();
        }

        $services = [];
        
        // Service Taxi
        $services[] = [
            'id' => 'taxi',
            'name' => 'Taxi',
            'icon' => 'car',
            'color' => 'blue',
            'description' => 'Déplacements rapides et sécurisés partout au Mali. Chauffeurs professionnels et véhicules confortables.',
            'features' => [
                'Disponible 24/7',
                'Tarifs transparents',
                'Suivi en temps réel',
            ],
        ];

        // Service Livraison
        $services[] = [
            'id' => 'delivery',
            'name' => 'Livraison',
            'icon' => 'package',
            'color' => 'green',
            'description' => 'Envoyez et recevez vos colis rapidement. Suivi en temps réel et livraison garantie.',
            'features' => [
                'Livraison express',
                'Assurance colis',
                'Preuve de livraison',
            ],
        ];

        // Service MoovMoney
        $services[] = [
            'id' => 'moovmoney',
            'name' => 'MoovMoney',
            'icon' => 'money',
            'color' => 'orange',
            'description' => 'Dépôt et retrait d\'argent à domicile. Un agent se rend chez vous pour vos transactions.',
            'features' => [
                'Service à domicile',
                'Sécurisé et rapide',
                'Sans frais cachés',
            ],
        ];

        return [
            'heading' => $home->service_heading_1 ?? 'Nos Services',
            'subheading' => $home->service_heading_2 ?? 'Une plateforme complète pour tous vos besoins',
            'description' => $home->service_para ?? '',
            'items' => $services,
        ];
    }

    /**
     * Formater la section Features
     */
    private function formatFeaturesSection($home)
    {
        if (!$home) {
            return $this->getDefaultFeatures();
        }

        $features = [];

        if ($home->feature_sub_heading_1) {
            $features[] = [
                'title' => $home->feature_sub_heading_1,
                'description' => $home->feature_sub_para_1,
                'icon' => 'clock',
            ];
        }

        if ($home->feature_sub_heading_2) {
            $features[] = [
                'title' => $home->feature_sub_heading_2,
                'description' => $home->feature_sub_para_2,
                'icon' => 'shield',
            ];
        }

        if ($home->feature_sub_heading_3) {
            $features[] = [
                'title' => $home->feature_sub_heading_3,
                'description' => $home->feature_sub_para_3,
                'icon' => 'star',
            ];
        }

        if ($home->feature_sub_heading_4) {
            $features[] = [
                'title' => $home->feature_sub_heading_4,
                'description' => $home->feature_sub_para_4,
                'icon' => 'users',
            ];
        }

        return [
            'heading' => $home->feature_heading ?? 'Pourquoi ChapChap ?',
            'description' => $home->feature_para ?? '',
            'items' => $features,
        ];
    }

    /**
     * Formater la section Driver
     */
    private function formatDriverSection($driver)
    {
        if (!$driver) {
            return null;
        }

        return [
            'heading' => $driver->heading ?? 'Devenez Chauffeur',
            'description' => $driver->description ?? '',
            'benefits' => [
                [
                    'title' => $driver->benefit_1_title ?? 'Revenus attractifs',
                    'description' => $driver->benefit_1_description ?? '',
                ],
                [
                    'title' => $driver->benefit_2_title ?? 'Horaires flexibles',
                    'description' => $driver->benefit_2_description ?? '',
                ],
                [
                    'title' => $driver->benefit_3_title ?? 'Support 24/7',
                    'description' => $driver->benefit_3_description ?? '',
                ],
            ],
            'cta' => $driver->cta_text ?? 'S\'inscrire comme chauffeur',
        ];
    }

    /**
     * Formater la section User
     */
    private function formatUserSection($user)
    {
        if (!$user) {
            return null;
        }

        return [
            'heading' => $user->heading ?? 'Comment ça marche',
            'steps' => [
                [
                    'number' => 1,
                    'title' => $user->step_1_title ?? 'Télécharger l\'app',
                    'description' => $user->step_1_description ?? '',
                ],
                [
                    'number' => 2,
                    'title' => $user->step_2_title ?? 'Créer un compte',
                    'description' => $user->step_2_description ?? '',
                ],
                [
                    'number' => 3,
                    'title' => $user->step_3_title ?? 'Commander',
                    'description' => $user->step_3_description ?? '',
                ],
                [
                    'number' => 4,
                    'title' => $user->step_4_title ?? 'Profiter',
                    'description' => $user->step_4_description ?? '',
                ],
            ],
        ];
    }

    /**
     * Formater la section About
     */
    private function formatAboutSection($about)
    {
        if (!$about) {
            return null;
        }

        return [
            'title' => $about->title ?? 'À propos de ChapChap',
            'description' => $about->description ?? '',
            'image' => $about->image ? $this->getImageUrl($about->image) : null,
            'mission' => $about->mission ?? '',
            'vision' => $about->vision ?? '',
        ];
    }

    /**
     * Formater la section Contact
     */
    private function formatContactSection($contact)
    {
        if (!$contact) {
            return null;
        }

        return [
            'heading' => $contact->heading ?? 'Contactez-nous',
            'email' => $contact->email ?? '',
            'phone' => $contact->phone ?? '',
            'address' => $contact->address ?? '',
            'social' => [
                'facebook' => $contact->facebook ?? '',
                'twitter' => $contact->twitter ?? '',
                'instagram' => $contact->instagram ?? '',
                'linkedin' => $contact->linkedin ?? '',
            ],
        ];
    }

    /**
     * Formater la section Downloads
     */
    private function formatDownloadsSection($home)
    {
        if (!$home) {
            return null;
        }

        return [
            'user_app' => [
                'android' => $home->hero_user_link_android ?? '',
                'ios' => $home->hero_user_link_apple ?? '',
            ],
            'driver_app' => [
                'android' => $home->hero_driver_link_android ?? '',
                'ios' => $home->hero_driver_link_apple ?? '',
            ],
        ];
    }

    /**
     * Formater la section Footer
     */
    private function formatFooterSection($quickLinks, $contact)
    {
        return [
            'privacy_policy' => $quickLinks->privacy ?? '',
            'terms_conditions' => $quickLinks->terms ?? '',
            'copyright' => '© ' . date('Y') . ' ChapChap. Tous droits réservés.',
            'contact' => $this->formatContactSection($contact),
        ];
    }

    /**
     * Obtenir l'URL complète d'une image
     */
    private function getImageUrl($path)
    {
        if (empty($path)) {
            return null;
        }

        return Storage::disk(env('FILESYSTEM_DRIVER'))->url($path);
    }

    /**
     * Services par défaut si aucune donnée en DB
     */
    private function getDefaultServices()
    {
        return [
            'heading' => 'Nos Services',
            'subheading' => 'Une plateforme complète',
            'items' => [
                [
                    'id' => 'taxi',
                    'name' => 'Taxi',
                    'icon' => 'car',
                    'color' => 'blue',
                    'description' => 'Déplacements rapides et sécurisés',
                    'features' => ['24/7', 'Tarifs transparents', 'Suivi temps réel'],
                ],
                [
                    'id' => 'delivery',
                    'name' => 'Livraison',
                    'icon' => 'package',
                    'color' => 'green',
                    'description' => 'Livraison rapide de colis',
                    'features' => ['Express', 'Assurance', 'Preuve de livraison'],
                ],
                [
                    'id' => 'moovmoney',
                    'name' => 'MoovMoney',
                    'icon' => 'money',
                    'color' => 'orange',
                    'description' => 'Transactions à domicile',
                    'features' => ['À domicile', 'Sécurisé', 'Sans frais cachés'],
                ],
            ],
        ];
    }

    /**
     * Features par défaut
     */
    private function getDefaultFeatures()
    {
        return [
            'heading' => 'Pourquoi ChapChap ?',
            'items' => [
                ['title' => 'Rapide', 'description' => 'Service en quelques minutes', 'icon' => 'clock'],
                ['title' => 'Sécurisé', 'description' => 'Transactions sécurisées', 'icon' => 'shield'],
                ['title' => 'Fiable', 'description' => 'Service de qualité', 'icon' => 'star'],
                ['title' => 'Support', 'description' => 'Assistance 24/7', 'icon' => 'users'],
            ],
        ];
    }
}
