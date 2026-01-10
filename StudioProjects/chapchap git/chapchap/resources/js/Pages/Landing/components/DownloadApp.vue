<template>
  <section id="download" class="py-20 bg-blue-600 relative overflow-hidden">
    <!-- Background Pattern -->
    <div class="absolute inset-0 opacity-10">
      <div class="absolute top-0 left-0 w-96 h-96 bg-white rounded-full blur-3xl"></div>
      <div class="absolute bottom-0 right-0 w-96 h-96 bg-white rounded-full blur-3xl"></div>
    </div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid lg:grid-cols-2 gap-12 items-center">
        <!-- Content -->
        <div class="text-white" data-aos="fade-right">
          <h2 class="text-3xl sm:text-4xl lg:text-5xl font-bold mb-6">
            Téléchargez l'application ChapChap
          </h2>
          <p class="text-lg text-blue-100 mb-8 leading-relaxed">
            Disponible gratuitement sur iOS et Android. Profitez de tous nos services en quelques clics.
          </p>

          <!-- Features List -->
          <ul class="space-y-4 mb-10">
            <li class="flex items-start space-x-3">
              <svg class="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span class="text-blue-50">Interface simple et intuitive</span>
            </li>
            <li class="flex items-start space-x-3">
              <svg class="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span class="text-blue-50">Suivi en temps réel de vos commandes</span>
            </li>
            <li class="flex items-start space-x-3">
              <svg class="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span class="text-blue-50">Paiement sécurisé et flexible</span>
            </li>
            <li class="flex items-start space-x-3">
              <svg class="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <span class="text-blue-50">Support client 24/7</span>
            </li>
          </ul>

          <!-- App Store Badges -->
          <div class="space-y-4">
            <p class="text-sm text-blue-100 font-medium mb-4">Télécharger maintenant :</p>
            
            <div class="flex flex-col sm:flex-row gap-4">
              <!-- Google Play -->
              <a 
                v-if="downloads.user_app.android"
                :href="downloads.user_app.android" 
                target="_blank"
                class="inline-flex items-center px-6 py-3 bg-black text-white rounded-lg hover:bg-gray-900 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
              >
                <svg class="w-8 h-8 mr-3" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                </svg>
                <div class="text-left">
                  <div class="text-xs">Disponible sur</div>
                  <div class="text-sm font-semibold">Google Play</div>
                </div>
              </a>

              <!-- App Store -->
              <a 
                v-if="downloads.user_app.ios"
                :href="downloads.user_app.ios" 
                target="_blank"
                class="inline-flex items-center px-6 py-3 bg-black text-white rounded-lg hover:bg-gray-900 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
              >
                <svg class="w-8 h-8 mr-3" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71,19.5C17.88,20.74 17,21.95 15.66,21.97C14.32,22 13.89,21.18 12.37,21.18C10.84,21.18 10.37,21.95 9.1,22C7.79,22.05 6.8,20.68 5.96,19.47C4.25,17 2.94,12.45 4.7,9.39C5.57,7.87 7.13,6.91 8.82,6.88C10.1,6.86 11.32,7.75 12.11,7.75C12.89,7.75 14.37,6.68 15.92,6.84C16.57,6.87 18.39,7.1 19.56,8.82C19.47,8.88 17.39,10.1 17.41,12.63C17.44,15.65 20.06,16.66 20.09,16.67C20.06,16.74 19.67,18.11 18.71,19.5M13,3.5C13.73,2.67 14.94,2.04 15.94,2C16.07,3.17 15.6,4.35 14.9,5.19C14.21,6.04 13.07,6.7 11.95,6.61C11.8,5.46 12.36,4.26 13,3.5Z"/>
                </svg>
                <div class="text-left">
                  <div class="text-xs">Télécharger sur</div>
                  <div class="text-sm font-semibold">App Store</div>
                </div>
              </a>
            </div>

            <!-- QR Code Option -->
            <div class="pt-6">
              <button 
                @click="showQR = !showQR"
                class="text-sm text-blue-100 hover:text-white flex items-center space-x-2 transition-colors duration-200"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
                </svg>
                <span>Scanner le QR Code</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Phone Mockup -->
        <div class="relative" data-aos="fade-left">
          <div class="relative mx-auto max-w-sm lg:max-w-md">
            <!-- Main Phone -->
            <div class="relative z-10 bg-gray-900 rounded-[3rem] p-4 shadow-2xl">
              <div class="aspect-[9/19] bg-gradient-to-br from-blue-500 to-blue-600 rounded-[2.5rem] overflow-hidden">
                <!-- App Screenshot Placeholder -->
                <div class="h-full flex flex-col items-center justify-center p-8 text-white">
                  <svg class="w-24 h-24 mb-6 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                  </svg>
                  <p class="text-center text-sm opacity-80">Screenshot de l'application</p>
                </div>
              </div>
            </div>

            <!-- Floating Elements -->
            <div class="absolute -top-8 -right-8 w-32 h-32 bg-white/20 rounded-full blur-2xl animate-pulse"></div>
            <div class="absolute -bottom-8 -left-8 w-32 h-32 bg-white/20 rounded-full blur-2xl animate-pulse" style="animation-delay: 1s;"></div>
          </div>

          <!-- QR Code Modal -->
          <transition
            enter-active-class="transition duration-200 ease-out"
            enter-from-class="opacity-0 scale-95"
            enter-to-class="opacity-100 scale-100"
            leave-active-class="transition duration-150 ease-in"
            leave-from-class="opacity-100 scale-100"
            leave-to-class="opacity-0 scale-95"
          >
            <div v-if="showQR" class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-white p-8 rounded-2xl shadow-2xl z-20">
              <button 
                @click="showQR = false"
                class="absolute top-2 right-2 p-2 text-gray-400 hover:text-gray-600 transition-colors duration-200"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
              <div class="text-center">
                <h3 class="text-lg font-bold text-gray-900 mb-4">Scanner pour télécharger</h3>
                <div class="w-48 h-48 bg-gray-100 rounded-lg flex items-center justify-center">
                  <p class="text-sm text-gray-500">QR Code</p>
                </div>
              </div>
            </div>
          </transition>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  data: {
    type: Object,
    default: () => ({})
  }
});

const showQR = ref(false);

const downloads = computed(() => props.data?.downloads || {
  user_app: {
    android: 'https://play.google.com/store',
    ios: 'https://apps.apple.com'
  },
  driver_app: {
    android: 'https://play.google.com/store',
    ios: 'https://apps.apple.com'
  }
});
</script>
