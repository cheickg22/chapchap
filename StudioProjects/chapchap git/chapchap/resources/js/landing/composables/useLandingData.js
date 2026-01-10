import { ref, onMounted } from 'vue';
import axios from 'axios';

export function useLandingData() {
  const data = ref(null);
  const loading = ref(true);
  const error = ref(null);

  const fetchLandingData = async (locale = 'fr') => {
    try {
      loading.value = true;
      error.value = null;

      const response = await axios.get('/api/v1/common/landing-page', {
        params: { locale }
      });

      if (response.data.success) {
        data.value = response.data.data;
      } else {
        throw new Error('Failed to fetch landing page data');
      }
    } catch (err) {
      console.error('Error fetching landing data:', err);
      error.value = err.message;
      
      // Fallback data si l'API échoue
      data.value = getDefaultData();
    } finally {
      loading.value = false;
    }
  };

  // Données par défaut si l'API échoue
  const getDefaultData = () => ({
    hero: {
      title: 'Transport et Livraison Rapide au Mali',
      subtitle: 'Taxi, Livraison, MoovMoney - Tout en un',
      cta_primary: 'Commander maintenant',
      cta_secondary: 'Devenir chauffeur',
      stats: {
        rides: '10K+',
        drivers: '500+',
        cities: '5'
      }
    },
    services: {
      heading: 'Nos Services',
      subheading: 'Une plateforme complète pour tous vos besoins',
      items: [
        {
          id: 'taxi',
          name: 'Taxi',
          icon: 'car',
          color: 'blue',
          description: 'Déplacements rapides et sécurisés partout au Mali.',
          features: ['Disponible 24/7', 'Tarifs transparents', 'Suivi en temps réel']
        },
        {
          id: 'delivery',
          name: 'Livraison',
          icon: 'package',
          color: 'green',
          description: 'Envoyez et recevez vos colis rapidement.',
          features: ['Livraison express', 'Assurance colis', 'Preuve de livraison']
        },
        {
          id: 'moovmoney',
          name: 'MoovMoney',
          icon: 'money',
          color: 'orange',
          description: 'Dépôt et retrait d\'argent à domicile.',
          features: ['Service à domicile', 'Sécurisé et rapide', 'Sans frais cachés']
        }
      ]
    },
    features: {
      heading: 'Pourquoi ChapChap ?',
      items: [
        { title: 'Rapide', description: 'Service en quelques minutes', icon: 'clock' },
        { title: 'Sécurisé', description: 'Transactions sécurisées', icon: 'shield' },
        { title: 'Fiable', description: 'Service de qualité', icon: 'star' },
        { title: 'Support', description: 'Assistance 24/7', icon: 'users' }
      ]
    },
    user: {
      heading: 'Comment ça marche',
      steps: [
        { number: 1, title: 'Télécharger l\'app', description: 'Disponible sur iOS et Android' },
        { number: 2, title: 'Créer un compte', description: 'Inscription rapide et gratuite' },
        { number: 3, title: 'Commander', description: 'Choisissez votre service' },
        { number: 4, title: 'Profiter', description: 'Service rapide et fiable' }
      ]
    },
    downloads: {
      user_app: {
        android: 'https://play.google.com/store',
        ios: 'https://apps.apple.com'
      },
      driver_app: {
        android: 'https://play.google.com/store',
        ios: 'https://apps.apple.com'
      }
    },
    contact: {
      heading: 'Contactez-nous',
      email: 'contact@chapchap.com',
      phone: '+223 XX XX XX XX',
      address: 'Bamako, Mali',
      social: {
        facebook: '',
        twitter: '',
        instagram: '',
        linkedin: ''
      }
    },
    footer: {
      copyright: `© ${new Date().getFullYear()} ChapChap. Tous droits réservés.`
    }
  });

  onMounted(() => {
    fetchLandingData();
  });

  return {
    data,
    loading,
    error,
    fetchLandingData
  };
}
