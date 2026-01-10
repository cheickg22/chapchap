<template>
  <section id="how-it-works" class="py-20 bg-gradient-to-br from-gray-50 to-white">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section Header -->
      <div class="text-center mb-16" data-aos="fade-up">
        <h2 class="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
          {{ heading }}
        </h2>
        <p class="text-lg text-gray-600 max-w-2xl mx-auto">
          Commencez à utiliser ChapChap en quelques minutes seulement
        </p>
      </div>

      <!-- Steps -->
      <div class="relative">
        <!-- Connection Line (Desktop) -->
        <div class="hidden lg:block absolute top-1/2 left-0 right-0 h-1 bg-gradient-to-r from-blue-200 via-blue-400 to-blue-200 transform -translate-y-1/2" style="z-index: 0;"></div>

        <!-- Steps Grid -->
        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8 relative" style="z-index: 1;">
          <div 
            v-for="(step, index) in steps" 
            :key="step.number"
            class="relative"
            data-aos="fade-up"
            :data-aos-delay="index * 100"
          >
            <!-- Step Card -->
            <div class="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2 h-full">
              <!-- Step Number -->
              <div class="relative mb-6">
                <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center mx-auto shadow-lg">
                  <span class="text-2xl font-bold text-white">{{ step.number }}</span>
                </div>
                <!-- Checkmark for completed steps -->
                <div class="absolute -top-2 -right-2 w-6 h-6 bg-green-500 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                  </svg>
                </div>
              </div>

              <!-- Step Content -->
              <div class="text-center">
                <h3 class="text-xl font-bold text-gray-900 mb-3">
                  {{ step.title }}
                </h3>
                <p class="text-gray-600 leading-relaxed">
                  {{ step.description }}
                </p>
              </div>

              <!-- Step Icon/Illustration -->
              <div class="mt-6 flex justify-center">
                <div class="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center">
                  <!-- Icon based on step number -->
                  <svg v-if="step.number === 1" class="w-10 h-10 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                  </svg>
                  <svg v-else-if="step.number === 2" class="w-10 h-10 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                  </svg>
                  <svg v-else-if="step.number === 3" class="w-10 h-10 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"/>
                  </svg>
                  <svg v-else-if="step.number === 4" class="w-10 h-10 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                </div>
              </div>
            </div>

            <!-- Arrow (Desktop) -->
            <div v-if="index < steps.length - 1" class="hidden lg:block absolute top-1/2 -right-4 transform -translate-y-1/2 z-10">
              <svg class="w-8 h-8 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
              </svg>
            </div>
          </div>
        </div>
      </div>

      <!-- CTA -->
      <div class="text-center mt-16" data-aos="fade-up" data-aos-delay="400">
        <button class="inline-flex items-center px-8 py-4 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5">
          Commencer maintenant
          <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
          </svg>
        </button>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  data: {
    type: Object,
    default: () => ({})
  }
});

const heading = computed(() => 
  props.data?.heading || 
  'Comment ça marche'
);

const steps = computed(() => {
  if (props.data?.steps && props.data.steps.length > 0) {
    return props.data.steps;
  }
  
  // Default steps
  return [
    {
      number: 1,
      title: 'Télécharger l\'app',
      description: 'Disponible gratuitement sur iOS et Android. Installation rapide et simple.'
    },
    {
      number: 2,
      title: 'Créer un compte',
      description: 'Inscription en moins de 2 minutes. Aucune carte bancaire requise.'
    },
    {
      number: 3,
      title: 'Commander',
      description: 'Choisissez votre service : Taxi, Livraison ou MoovMoney.'
    },
    {
      number: 4,
      title: 'Profiter',
      description: 'Service rapide, fiable et sécurisé. Suivi en temps réel.'
    }
  ];
});
</script>

<style scoped>
/* Hover effect on cards */
.group:hover .opacity-0 {
  opacity: 1;
}

/* Pulse animation for step numbers */
@keyframes pulse-ring {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  100% {
    transform: scale(1.3);
    opacity: 0;
  }
}

.animate-pulse-ring {
  animation: pulse-ring 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>
