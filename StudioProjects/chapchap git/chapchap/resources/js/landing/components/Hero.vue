<template>
  <section class="relative bg-gradient-to-br from-blue-50 via-white to-blue-50 overflow-hidden">
    <!-- Decorative background -->
    <div class="absolute inset-0 overflow-hidden">
      <div class="absolute -top-40 -right-40 w-80 h-80 bg-blue-100 rounded-full opacity-20 blur-3xl"></div>
      <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-blue-100 rounded-full opacity-20 blur-3xl"></div>
    </div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-32">
      <div class="grid lg:grid-cols-2 gap-12 items-center">
        <!-- Content -->
        <div class="text-center lg:text-left" data-aos="fade-right">
          <!-- Badge -->
          <div class="inline-flex items-center px-4 py-2 bg-blue-100 text-blue-700 rounded-full text-sm font-medium mb-6">
            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
            </svg>
            #1 au Mali
          </div>

          <!-- Title -->
          <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 leading-tight mb-6" v-html="title"></h1>

          <!-- Subtitle -->
          <p class="text-lg sm:text-xl text-gray-600 mb-8 max-w-2xl mx-auto lg:mx-0">
            {{ subtitle }}
          </p>

          <!-- CTA Buttons -->
          <div class="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
            <button class="group inline-flex items-center justify-center px-8 py-4 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5">
              {{ ctaPrimary }}
              <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
              </svg>
            </button>

            <button class="inline-flex items-center justify-center px-8 py-4 bg-white text-gray-700 font-semibold rounded-lg border-2 border-gray-200 hover:border-blue-600 hover:text-blue-600 transition-all duration-300">
              {{ ctaSecondary }}
            </button>
          </div>

          <!-- Stats -->
          <div class="grid grid-cols-3 gap-6 mt-12 pt-12 border-t border-gray-200">
            <div>
              <div class="text-3xl font-bold text-gray-900">{{ stats.rides }}+</div>
              <div class="text-sm text-gray-600 mt-1">Courses</div>
            </div>
            <div>
              <div class="text-3xl font-bold text-gray-900">{{ stats.drivers }}+</div>
              <div class="text-sm text-gray-600 mt-1">Chauffeurs</div>
            </div>
            <div>
              <div class="text-3xl font-bold text-gray-900">{{ stats.cities }}</div>
              <div class="text-sm text-gray-600 mt-1">Villes</div>
            </div>
          </div>
        </div>

        <!-- Image/Illustration -->
        <div class="relative" data-aos="fade-left">
          <div class="relative z-10">
            <!-- Phone mockup -->
            <div class="relative mx-auto w-full max-w-md">
              <div class="relative bg-white rounded-3xl shadow-2xl p-4">
                <div class="aspect-[9/19] bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl overflow-hidden">
                  <!-- App screenshot placeholder -->
                  <div class="h-full flex items-center justify-center">
                    <div class="text-center text-white p-8">
                      <svg class="w-20 h-20 mx-auto mb-4 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                      </svg>
                      <p class="text-sm opacity-80">Screenshot de l'app</p>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- Floating cards -->
              <div class="absolute -top-4 -left-4 bg-white rounded-xl shadow-lg p-4 animate-float" data-aos="fade-up" data-aos-delay="200">
                <div class="flex items-center space-x-3">
                  <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                    <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    </svg>
                  </div>
                  <div>
                    <div class="text-xs text-gray-500">Course confirmée</div>
                    <div class="text-sm font-semibold text-gray-900">En 2 minutes</div>
                  </div>
                </div>
              </div>

              <div class="absolute -bottom-4 -right-4 bg-white rounded-xl shadow-lg p-4 animate-float-delayed" data-aos="fade-up" data-aos-delay="400">
                <div class="flex items-center space-x-3">
                  <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                    <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                  </div>
                  <div>
                    <div class="text-xs text-gray-500">Prix transparent</div>
                    <div class="text-sm font-semibold text-gray-900">Dès 500 FCFA</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed } from 'vue';

// Props pour recevoir les données depuis le parent
const props = defineProps({
  data: {
    type: Object,
    default: () => ({
      title: 'Transport et Livraison Rapide au Mali',
      subtitle: 'Taxi, Livraison, MoovMoney - Tout en un',
      cta_primary: 'Commander maintenant',
      cta_secondary: 'Devenir chauffeur',
      stats: {
        rides: '10K+',
        drivers: '500+',
        cities: '5'
      }
    })
  }
});

// Computed pour faciliter l'accès aux données
const title = computed(() => props.data?.title || 'Transport et Livraison Rapide au Mali');
const subtitle = computed(() => props.data?.subtitle || 'Taxi, Livraison, MoovMoney - Tout en un');
const ctaPrimary = computed(() => props.data?.cta_primary || 'Commander maintenant');
const ctaSecondary = computed(() => props.data?.cta_secondary || 'Devenir chauffeur');
const stats = computed(() => props.data?.stats || { rides: '10K+', drivers: '500+', cities: '5' });
</script>

<style scoped>
@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes float-delayed {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-15px);
  }
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 3s ease-in-out infinite 1.5s;
}
</style>
