<template>
  <section class="py-20 bg-white">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section Header -->
      <div class="text-center mb-16" data-aos="fade-up">
        <h2 class="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
          Nos Services
        </h2>
        <p class="text-lg text-gray-600 max-w-2xl mx-auto">
          Une plateforme complète pour tous vos besoins de transport et de services financiers
        </p>
      </div>

      <!-- Services Grid -->
      <div class="grid md:grid-cols-3 gap-8">
        <!-- Taxi Service -->
        <div 
          class="group relative bg-white rounded-2xl p-8 border-2 border-gray-100 hover:border-blue-500 transition-all duration-300 hover:shadow-xl"
          data-aos="fade-up"
          data-aos-delay="100"
        >
          <!-- Icon -->
          <div class="w-16 h-16 bg-blue-100 rounded-xl flex items-center justify-center mb-6 group-hover:bg-blue-600 transition-colors duration-300">
            <svg class="w-8 h-8 text-blue-600 group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/>
            </svg>
          </div>

          <!-- Content -->
          <h3 class="text-2xl font-bold text-gray-900 mb-3">
            Taxi
          </h3>
          <p class="text-gray-600 mb-6">
            Déplacements rapides et sécurisés partout au Mali. Chauffeurs professionnels et véhicules confortables.
          </p>

          <!-- Features -->
          <ul class="space-y-3 mb-6">
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Disponible 24/7
            </li>
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Tarifs transparents
            </li>
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Suivi en temps réel
            </li>
          </ul>

          <!-- CTA -->
          <button class="w-full py-3 bg-gray-50 text-gray-700 font-semibold rounded-lg group-hover:bg-blue-600 group-hover:text-white transition-all duration-300">
            Commander un taxi
          </button>
        </div>

        <!-- Delivery Service -->
        <div 
          class="group relative bg-white rounded-2xl p-8 border-2 border-gray-100 hover:border-green-500 transition-all duration-300 hover:shadow-xl"
          data-aos="fade-up"
          data-aos-delay="200"
        >
          <!-- Icon -->
          <div class="w-16 h-16 bg-green-100 rounded-xl flex items-center justify-center mb-6 group-hover:bg-green-600 transition-colors duration-300">
            <svg class="w-8 h-8 text-green-600 group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
            </svg>
          </div>

          <!-- Content -->
          <h3 class="text-2xl font-bold text-gray-900 mb-3">
            Livraison
          </h3>
          <p class="text-gray-600 mb-6">
            Envoyez et recevez vos colis rapidement. Suivi en temps réel et livraison garantie.
          </p>

          <!-- Features -->
          <ul class="space-y-3 mb-6">
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Livraison express
            </li>
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Assurance colis
            </li>
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Preuve de livraison
            </li>
          </ul>

          <!-- CTA -->
          <button class="w-full py-3 bg-gray-50 text-gray-700 font-semibold rounded-lg group-hover:bg-green-600 group-hover:text-white transition-all duration-300">
            Envoyer un colis
          </button>
        </div>

        <!-- MoovMoney Service -->
        <div 
          class="group relative bg-white rounded-2xl p-8 border-2 border-gray-100 hover:border-orange-500 transition-all duration-300 hover:shadow-xl"
          data-aos="fade-up"
          data-aos-delay="300"
        >
          <!-- Icon -->
          <div class="w-16 h-16 bg-orange-100 rounded-xl flex items-center justify-center mb-6 group-hover:bg-orange-600 transition-colors duration-300">
            <svg class="w-8 h-8 text-orange-600 group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
          </div>

          <!-- Content -->
          <h3 class="text-2xl font-bold text-gray-900 mb-3">
            MoovMoney
          </h3>
          <p class="text-gray-600 mb-6">
            Dépôt et retrait d'argent à domicile. Un agent se rend chez vous pour vos transactions.
          </p>

          <!-- Features -->
          <ul class="space-y-3 mb-6">
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Service à domicile
            </li>
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Sécurisé et rapide
            </li>
            <li class="flex items-center text-sm text-gray-600">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              Sans frais cachés
            </li>
          </ul>

          <!-- CTA -->
          <button class="w-full py-3 bg-gray-50 text-gray-700 font-semibold rounded-lg group-hover:bg-orange-600 group-hover:text-white transition-all duration-300">
            Faire une transaction
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
// No reactive data needed for this component
</script>
