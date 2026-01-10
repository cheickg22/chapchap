<template>
  <Layout>
    <PageHeader :title="$t('moov-money-settings')" :items="items" />
    
    <div class="row">
      <div class="col-lg-12">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">Configuration Moov Money</h5>
          </div>
          <div class="card-body">
            <form @submit.prevent="saveSettings">
              <!-- Mode Test -->
              <div class="row mb-4">
                <div class="col-md-12">
                  <div class="form-check form-switch">
                    <input 
                      class="form-check-input" 
                      type="checkbox" 
                      id="testMode"
                      v-model="settings.test_mode"
                    >
                    <label class="form-check-label" for="testMode">
                      <strong>Mode Test</strong>
                    </label>
                  </div>
                  <small class="text-muted">
                    En mode test, les transactions sont simulées sans appeler l'API Moov Money réelle.
                  </small>
                </div>
              </div>

              <!-- Configuration API -->
              <div class="row mb-4">
                <div class="col-md-6">
                  <label for="cashInUrl" class="form-label">URL Cash In</label>
                  <input 
                    type="url" 
                    class="form-control" 
                    id="cashInUrl"
                    v-model="settings.cash_in_url"
                    :disabled="settings.test_mode"
                    placeholder="https://api.moovmoney.ml:38443/apiaccess/IntegratingCashIn"
                  >
                </div>
                <div class="col-md-6">
                  <label for="cashOutUrl" class="form-label">URL Cash Out</label>
                  <input 
                    type="url" 
                    class="form-control" 
                    id="cashOutUrl"
                    v-model="settings.cash_out_url"
                    :disabled="settings.test_mode"
                    placeholder="https://api.moovmoney.ml:38443/apiaccess/IntegratingCashOut"
                  >
                </div>
              </div>

              <div class="row mb-4">
                <div class="col-md-4">
                  <label for="shortcode" class="form-label">Shortcode</label>
                  <input 
                    type="text" 
                    class="form-control" 
                    id="shortcode"
                    v-model="settings.shortcode"
                    :disabled="settings.test_mode"
                    placeholder="22300001009"
                  >
                </div>
                <div class="col-md-4">
                  <label for="username" class="form-label">Username</label>
                  <input 
                    type="text" 
                    class="form-control" 
                    id="username"
                    v-model="settings.username"
                    :disabled="settings.test_mode"
                    placeholder="00001009"
                  >
                </div>
                <div class="col-md-4">
                  <label for="password" class="form-label">Password</label>
                  <input 
                    type="password" 
                    class="form-control" 
                    id="password"
                    v-model="settings.password"
                    :disabled="settings.test_mode"
                    placeholder="••••••••••••"
                  >
                </div>
              </div>

              <!-- Taux de Commission -->
              <div class="row mb-4">
                <div class="col-md-6">
                  <label for="depositCommission" class="form-label">Commission Dépôt (%)</label>
                  <div class="input-group">
                    <input 
                      type="number" 
                      class="form-control" 
                      id="depositCommission"
                      v-model="settings.deposit_commission_rate"
                      min="0"
                      max="100"
                      step="0.1"
                    >
                    <span class="input-group-text">%</span>
                  </div>
                  <small class="text-muted">Commission prélevée sur les dépôts</small>
                </div>
                <div class="col-md-6">
                  <label for="withdrawalCommission" class="form-label">Commission Retrait (%)</label>
                  <div class="input-group">
                    <input 
                      type="number" 
                      class="form-control" 
                      id="withdrawalCommission"
                      v-model="settings.withdrawal_commission_rate"
                      min="0"
                      max="100"
                      step="0.1"
                    >
                    <span class="input-group-text">%</span>
                  </div>
                  <small class="text-muted">Commission prélevée sur les retraits</small>
                </div>
              </div>

              <!-- Limites -->
              <div class="row mb-4">
                <div class="col-md-6">
                  <label for="minAmount" class="form-label">Montant Minimum (XOF)</label>
                  <input 
                    type="number" 
                    class="form-control" 
                    id="minAmount"
                    v-model="settings.min_amount"
                    min="0"
                    step="100"
                  >
                </div>
                <div class="col-md-6">
                  <label for="maxAmount" class="form-label">Montant Maximum (XOF)</label>
                  <input 
                    type="number" 
                    class="form-control" 
                    id="maxAmount"
                    v-model="settings.max_amount"
                    min="0"
                    step="1000"
                  >
                </div>
              </div>

              <!-- Notifications -->
              <div class="row mb-4">
                <div class="col-md-12">
                  <h6>Notifications</h6>
                  <div class="form-check">
                    <input 
                      class="form-check-input" 
                      type="checkbox" 
                      id="emailNotifications"
                      v-model="settings.email_notifications"
                    >
                    <label class="form-check-label" for="emailNotifications">
                      Notifications par email pour les transactions
                    </label>
                  </div>
                  <div class="form-check">
                    <input 
                      class="form-check-input" 
                      type="checkbox" 
                      id="smsNotifications"
                      v-model="settings.sms_notifications"
                    >
                    <label class="form-check-label" for="smsNotifications">
                      Notifications SMS pour les transactions importantes
                    </label>
                  </div>
                </div>
              </div>

              <!-- Boutons d'action -->
              <div class="row">
                <div class="col-md-12">
                  <button type="submit" class="btn btn-primary me-2" :disabled="saving">
                    <i class="bx bx-save" v-if="!saving"></i>
                    <i class="bx bx-loader-alt bx-spin" v-else></i>
                    {{ saving ? 'Sauvegarde...' : 'Sauvegarder' }}
                  </button>
                  <button type="button" @click="testConnection" class="btn btn-outline-info me-2" :disabled="settings.test_mode || testing">
                    <i class="bx bx-test-tube" v-if="!testing"></i>
                    <i class="bx bx-loader-alt bx-spin" v-else></i>
                    {{ testing ? 'Test...' : 'Tester la Connexion' }}
                  </button>
                  <button type="button" @click="resetToDefaults" class="btn btn-outline-secondary">
                    <i class="bx bx-reset"></i>
                    Réinitialiser
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Statistiques de Configuration -->
    <div class="row mt-4">
      <div class="col-lg-12">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">État du Service</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-3">
                <div class="text-center">
                  <div class="avatar-sm mx-auto mb-3">
                    <span :class="serviceStatus.api_status === 'online' ? 'avatar-title bg-soft-success text-success' : 'avatar-title bg-soft-danger text-danger'" class="rounded-circle fs-3">
                      <i :class="serviceStatus.api_status === 'online' ? 'bx bx-check-circle' : 'bx bx-x-circle'"></i>
                    </span>
                  </div>
                  <h6>API Moov Money</h6>
                  <p class="text-muted mb-0">{{ serviceStatus.api_status === 'online' ? 'En ligne' : 'Hors ligne' }}</p>
                </div>
              </div>
              <div class="col-md-3">
                <div class="text-center">
                  <div class="avatar-sm mx-auto mb-3">
                    <span class="avatar-title bg-soft-info text-info rounded-circle fs-3">
                      <i class="bx bx-time"></i>
                    </span>
                  </div>
                  <h6>Dernière Transaction</h6>
                  <p class="text-muted mb-0">{{ serviceStatus.last_transaction || 'Aucune' }}</p>
                </div>
              </div>
              <div class="col-md-3">
                <div class="text-center">
                  <div class="avatar-sm mx-auto mb-3">
                    <span class="avatar-title bg-soft-warning text-warning rounded-circle fs-3">
                      <i class="bx bx-error"></i>
                    </span>
                  </div>
                  <h6>Erreurs (24h)</h6>
                  <p class="text-muted mb-0">{{ serviceStatus.error_count || 0 }}</p>
                </div>
              </div>
              <div class="col-md-3">
                <div class="text-center">
                  <div class="avatar-sm mx-auto mb-3">
                    <span class="avatar-title bg-soft-primary text-primary rounded-circle fs-3">
                      <i class="bx bx-trending-up"></i>
                    </span>
                  </div>
                  <h6>Taux de Réussite</h6>
                  <p class="text-muted mb-0">{{ serviceStatus.success_rate || 0 }}%</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";

export default {
  components: {
    Layout,
    PageHeader,
  },
  props: {
    currentSettings: Object,
  },
  data() {
    return {
      items: [
        {
          text: "Dashboard",
          href: "/",
        },
        {
          text: "Moov Money",
          href: "/moov-money-transactions",
        },
        {
          text: "Configuration",
          active: true,
        },
      ],
      settings: {
        test_mode: true,
        cash_in_url: 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashIn',
        cash_out_url: 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashOut',
        shortcode: '22300001009',
        username: '00001009',
        password: '',
        deposit_commission_rate: 2.0,
        withdrawal_commission_rate: 2.5,
        min_amount: 500,
        max_amount: 1000000,
        email_notifications: true,
        sms_notifications: false,
      },
      serviceStatus: {
        api_status: 'online',
        last_transaction: null,
        error_count: 0,
        success_rate: 0,
      },
      saving: false,
      testing: false,
    };
  },
  mounted() {
    if (this.currentSettings) {
      this.settings = { ...this.settings, ...this.currentSettings };
    }
    this.loadServiceStatus();
  },
  methods: {
    async saveSettings() {
      this.saving = true;
      try {
        const response = await axios.post('/moov-money-settings/save', this.settings);
        
        this.$toast.success('Configuration sauvegardée avec succès');
        
        // Recharger la page si le mode test a changé
        if (response.data.reload_required) {
          setTimeout(() => {
            window.location.reload();
          }, 1000);
        }
      } catch (error) {
        console.error('Erreur lors de la sauvegarde:', error);
        this.$toast.error('Erreur lors de la sauvegarde de la configuration');
      } finally {
        this.saving = false;
      }
    },
    
    async testConnection() {
      if (this.settings.test_mode) {
        this.$toast.warning('Désactivez le mode test pour tester la connexion réelle');
        return;
      }
      
      this.testing = true;
      try {
        const response = await axios.post('/moov-money-settings/test-connection', {
          cash_in_url: this.settings.cash_in_url,
          cash_out_url: this.settings.cash_out_url,
          shortcode: this.settings.shortcode,
          username: this.settings.username,
          password: this.settings.password,
        });
        
        if (response.data.success) {
          this.$toast.success('Connexion à l\'API Moov Money réussie');
        } else {
          this.$toast.error('Échec de la connexion: ' + response.data.message);
        }
      } catch (error) {
        console.error('Erreur lors du test de connexion:', error);
        this.$toast.error('Erreur lors du test de connexion');
      } finally {
        this.testing = false;
      }
    },
    
    resetToDefaults() {
      if (confirm('Êtes-vous sûr de vouloir réinitialiser la configuration aux valeurs par défaut ?')) {
        this.settings = {
          test_mode: true,
          cash_in_url: 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashIn',
          cash_out_url: 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashOut',
          shortcode: '22300001009',
          username: '00001009',
          password: '',
          deposit_commission_rate: 2.0,
          withdrawal_commission_rate: 2.5,
          min_amount: 500,
          max_amount: 1000000,
          email_notifications: true,
          sms_notifications: false,
        };
      }
    },
    
    async loadServiceStatus() {
      try {
        const response = await axios.get('/moov-money-settings/status');
        this.serviceStatus = response.data;
      } catch (error) {
        console.error('Erreur lors du chargement du statut du service:', error);
      }
    },
  }
};
</script>

<style scoped>
.form-check-input:checked {
  background-color: #28a745;
  border-color: #28a745;
}

.avatar-title {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
}
</style>
