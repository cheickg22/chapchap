<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-200 transition-all duration-300" :class="{ 'shadow-lg': scrolled }">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16 lg:h-20">
        <!-- Logo -->
        <div class="flex-shrink-0">
          <a href="#" class="flex items-center space-x-2">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold text-xl">C</span>
            </div>
            <span class="text-2xl font-bold text-gray-900">ChapChap</span>
          </a>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden lg:flex lg:items-center lg:space-x-8">
          <a 
            v-for="item in navItems" 
            :key="item.id"
            :href="item.href" 
            class="text-gray-700 hover:text-blue-600 font-medium transition-colors duration-200 relative group"
          >
            {{ item.label }}
            <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-blue-600 transition-all duration-300 group-hover:w-full"></span>
          </a>
        </div>

        <!-- Desktop CTA Buttons -->
        <div class="hidden lg:flex lg:items-center lg:space-x-4">
          <button class="px-6 py-2.5 text-gray-700 font-semibold hover:text-blue-600 transition-colors duration-200">
            Se connecter
          </button>
          <button class="px-6 py-2.5 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-all duration-200 shadow-md hover:shadow-lg transform hover:-translate-y-0.5">
            Télécharger l'app
          </button>
        </div>

        <!-- Mobile Menu Button -->
        <div class="lg:hidden">
          <button 
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="p-2 rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200"
            aria-label="Toggle menu"
          >
            <svg v-if="!mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
            <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile Menu -->
    <transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-4"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-4"
    >
      <div v-if="mobileMenuOpen" class="lg:hidden border-t border-gray-200 bg-white">
        <div class="px-4 py-6 space-y-4">
          <!-- Mobile Navigation Links -->
          <a 
            v-for="item in navItems" 
            :key="item.id"
            :href="item.href"
            @click="mobileMenuOpen = false"
            class="block px-4 py-3 text-gray-700 font-medium hover:bg-blue-50 hover:text-blue-600 rounded-lg transition-all duration-200"
          >
            {{ item.label }}
          </a>

          <!-- Mobile CTA Buttons -->
          <div class="pt-4 space-y-3 border-t border-gray-200">
            <button 
              class="w-full px-6 py-3 text-gray-700 font-semibold border-2 border-gray-200 rounded-lg hover:border-blue-600 hover:text-blue-600 transition-all duration-200"
              @click="mobileMenuOpen = false"
            >
              Se connecter
            </button>
            <button 
              class="w-full px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-all duration-200 shadow-md"
              @click="mobileMenuOpen = false"
            >
              Télécharger l'app
            </button>
          </div>

          <!-- Mobile Language Selector -->
          <div class="pt-4 border-t border-gray-200">
            <select 
              v-model="selectedLocale"
              @change="changeLocale"
              class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg text-gray-700 font-medium focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="fr">🇫🇷 Français</option>
              <option value="en">🇬🇧 English</option>
            </select>
          </div>
        </div>
      </div>
    </transition>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

// Props
const props = defineProps({
  data: {
    type: Object,
    default: () => ({})
  }
});

// Emits
const emit = defineEmits(['locale-changed']);

// State
const mobileMenuOpen = ref(false);
const scrolled = ref(false);
const selectedLocale = ref('fr');

// Navigation items
const navItems = ref([
  { id: 'services', label: 'Services', href: '#services' },
  { id: 'features', label: 'Fonctionnalités', href: '#features' },
  { id: 'how-it-works', label: 'Comment ça marche', href: '#how-it-works' },
  { id: 'download', label: 'Télécharger', href: '#download' },
  { id: 'contact', label: 'Contact', href: '#contact' },
]);

// Handle scroll
const handleScroll = () => {
  scrolled.value = window.scrollY > 20;
};

// Change locale
const changeLocale = () => {
  emit('locale-changed', selectedLocale.value);
  mobileMenuOpen.value = false;
};

// Close mobile menu on escape key
const handleEscape = (e) => {
  if (e.key === 'Escape') {
    mobileMenuOpen.value = false;
  }
};

// Smooth scroll to anchor
const smoothScroll = (e) => {
  const href = e.target.getAttribute('href');
  if (href && href.startsWith('#')) {
    e.preventDefault();
    const element = document.querySelector(href);
    if (element) {
      const offset = 80; // Navbar height
      const elementPosition = element.getBoundingClientRect().top;
      const offsetPosition = elementPosition + window.pageYOffset - offset;

      window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth'
      });
      mobileMenuOpen.value = false;
    }
  }
};

// Lifecycle
onMounted(() => {
  window.addEventListener('scroll', handleScroll);
  window.addEventListener('keydown', handleEscape);
  
  // Add click listeners for smooth scroll
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', smoothScroll);
  });
});

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll);
  window.removeEventListener('keydown', handleEscape);
});
</script>

<style scoped>
/* Prevent body scroll when mobile menu is open */
body:has(.mobile-menu-open) {
  overflow: hidden;
}

/* Smooth transitions */
* {
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Active link indicator */
.router-link-active {
  @apply text-blue-600;
}

.router-link-active::after {
  @apply w-full;
}
</style>
