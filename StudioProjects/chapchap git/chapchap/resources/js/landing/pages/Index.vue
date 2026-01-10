<template>
  <div class="min-h-screen bg-white">
    <!-- Navbar -->
    <Navbar :data="landingData?.hero" @locale-changed="handleLocaleChange" />

    <!-- Loading State -->
    <div v-if="loading" class="min-h-screen flex items-center justify-center">
      <div class="text-center">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        <p class="mt-4 text-gray-600">Chargement...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="min-h-screen flex items-center justify-center">
      <div class="text-center">
        <svg class="w-16 h-16 text-red-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <p class="text-gray-600">{{ error }}</p>
        <button 
          @click="retryFetch"
          class="mt-4 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200"
        >
          Réessayer
        </button>
      </div>
    </div>

    <!-- Main Content -->
    <main v-else>
      <!-- Hero Section -->
      <Hero :data="landingData?.hero" />

      <!-- Services Section -->
      <Services :data="landingData?.services" />

      <!-- Features Section (if available) -->
      <section v-if="landingData?.features" id="features" class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-16" data-aos="fade-up">
            <h2 class="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              {{ landingData.features.heading }}
            </h2>
            <p v-if="landingData.features.description" class="text-lg text-gray-600 max-w-2xl mx-auto">
              {{ landingData.features.description }}
            </p>
          </div>

          <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div 
              v-for="(feature, index) in landingData.features.items" 
              :key="index"
              class="text-center p-6"
              data-aos="fade-up"
              :data-aos-delay="index * 100"
            >
              <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
              </div>
              <h3 class="text-xl font-bold text-gray-900 mb-2">{{ feature.title }}</h3>
              <p class="text-gray-600">{{ feature.description }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- How It Works Section -->
      <HowItWorks :data="landingData?.user" />

      <!-- Download App Section -->
      <DownloadApp :data="landingData" />

      <!-- Contact Section (if available) -->
      <section v-if="landingData?.contact" id="contact" class="py-20 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-12" data-aos="fade-up">
            <h2 class="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              {{ landingData.contact.heading }}
            </h2>
          </div>

          <div class="grid md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            <div v-if="landingData.contact.email" class="text-center p-6 bg-white rounded-xl shadow-md" data-aos="fade-up">
              <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <h3 class="font-semibold text-gray-900 mb-2">Email</h3>
              <a :href="`mailto:${landingData.contact.email}`" class="text-blue-600 hover:text-blue-700">
                {{ landingData.contact.email }}
              </a>
            </div>

            <div v-if="landingData.contact.phone" class="text-center p-6 bg-white rounded-xl shadow-md" data-aos="fade-up" data-aos-delay="100">
              <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
                </svg>
              </div>
              <h3 class="font-semibold text-gray-900 mb-2">Téléphone</h3>
              <a :href="`tel:${landingData.contact.phone}`" class="text-blue-600 hover:text-blue-700">
                {{ landingData.contact.phone }}
              </a>
            </div>

            <div v-if="landingData.contact.address" class="text-center p-6 bg-white rounded-xl shadow-md" data-aos="fade-up" data-aos-delay="200">
              <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
              </div>
              <h3 class="font-semibold text-gray-900 mb-2">Adresse</h3>
              <p class="text-gray-600">{{ landingData.contact.address }}</p>
            </div>
          </div>
        </div>
      </section>
    </main>

    <!-- Footer -->
    <Footer :data="landingData" />

    <!-- Scroll to Top Button -->
    <transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <button
        v-if="showScrollTop"
        @click="scrollToTop"
        class="fixed bottom-8 right-8 w-12 h-12 bg-blue-600 text-white rounded-full shadow-lg hover:bg-blue-700 transition-all duration-200 flex items-center justify-center z-40"
        aria-label="Scroll to top"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18"/>
        </svg>
      </button>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useLandingData } from '../composables/useLandingData';
import Navbar from '../components/Navbar.vue';
import Hero from '../components/Hero.vue';
import Services from '../components/Services.vue';
import HowItWorks from '../components/HowItWorks.vue';
import DownloadApp from '../components/DownloadApp.vue';
import Footer from '../components/Footer.vue';
import AOS from 'aos';
import 'aos/dist/aos.css';

// Use landing data composable
const { data: landingData, loading, error, fetchLandingData } = useLandingData();

// Scroll to top button
const showScrollTop = ref(false);

// Handle scroll
const handleScroll = () => {
  showScrollTop.value = window.scrollY > 300;
};

// Scroll to top
const scrollToTop = () => {
  window.scrollTo({
    top: 0,
    behavior: 'smooth'
  });
};

// Handle locale change
const handleLocaleChange = (locale) => {
  fetchLandingData(locale);
};

// Retry fetch
const retryFetch = () => {
  fetchLandingData();
};

// Lifecycle
onMounted(() => {
  // Initialize AOS
  AOS.init({
    duration: 800,
    once: true,
    offset: 100
  });

  // Add scroll listener
  window.addEventListener('scroll', handleScroll);
});

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll);
});
</script>

<style>
/* Global styles for landing page */
html {
  scroll-behavior: smooth;
}

/* AOS animations */
[data-aos] {
  pointer-events: auto;
}
</style>
