<template>
  <Layout>
    <PageHeader :title="$t('moov-money-logs')" :items="items" />
    
    <!-- Filtres -->
    <div class="row mb-4">
      <div class="col-lg-12">
        <div class="card">
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-3">
                <label class="form-label">Période</label>
                <select v-model="filters.period" class="form-select" @change="loadLogs">
                  <option value="1">Dernières 24h</option>
                  <option value="7">7 derniers jours</option>
                  <option value="30">30 derniers jours</option>
                  <option value="90">90 derniers jours</option>
                </select>
              </div>
              <div class="col-md-3">
                <label class="form-label">Niveau</label>
                <select v-model="filters.level" class="form-select" @change="loadLogs">
                  <option value="all">Tous</option>
                  <option value="error">Erreurs</option>
                  <option value="warning">Avertissements</option>
                  <option value="info">Informations</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Recherche</label>
                <input 
                  type="text" 
                  v-model="filters.search" 
                  class="form-control" 
                  placeholder="ID transaction, téléphone, nom..."
                  @keyup.enter="loadLogs"
                >
              </div>
              <div class="col-md-2">
                <label class="form-label">&nbsp;</label>
                <div class="d-flex gap-2">
                  <button @click="loadLogs" class="btn btn-primary">
                    <i class="bx bx-search"></i>
                  </button>
                  <button @click="clearFilters" class="btn btn-outline-secondary">
                    <i class="bx bx-reset"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Actions rapides -->
    <div class="row mb-4">
      <div class="col-lg-12">
        <div class="card">
          <div class="card-body">
            <div class="d-flex justify-content-between align-items-center">
              <div>
                <h6 class="mb-0">Actions Rapides</h6>
                <small class="text-muted">Outils de diagnostic et maintenance</small>
              </div>
              <div class="d-flex gap-2">
                <button @click="forceSync" class="btn btn-outline-info" :disabled="syncing">
                  <i class="bx bx-sync" :class="{ 'bx-spin': syncing }"></i>
                  {{ syncing ? 'Synchronisation...' : 'Forcer la Sync' }}
                </button>
                <button @click="exportLogs" class="btn btn-outline-success">
                  <i class="bx bx-download"></i>
                  Exporter les Logs
                </button>
                <button @click="loadLogs" class="btn btn-outline-primary">
                  <i class="bx bx-refresh"></i>
                  Actualiser
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Logs -->
    <div class="row">
      <div class="col-lg-12">
        <div class="card">
          <div class="card-header">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="card-title mb-0">Journal des Transactions</h5>
              <div class="d-flex align-items-center gap-2">
                <span class="badge bg-secondary">{{ pagination?.total || 0 }} entrées</span>
                <div class="form-check form-switch">
                  <input 
                    class="form-check-input" 
                    type="checkbox" 
                    id="autoRefresh"
                    v-model="autoRefresh"
                    @change="toggleAutoRefresh"
                  >
                  <label class="form-check-label" for="autoRefresh">
                    Auto-actualisation
                  </label>
                </div>
              </div>
            </div>
          </div>
          <div class="card-body">
            <div v-if="loading" class="text-center py-4">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Chargement...</span>
              </div>
            </div>
            
            <div v-else-if="logs.length === 0" class="text-center py-4 text-muted">
              <i class="bx bx-info-circle fs-1"></i>
              <p class="mt-2">Aucun log trouvé pour les critères sélectionnés</p>
            </div>
            
            <div v-else class="table-responsive">
              <table class="table table-hover table-nowrap align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Timestamp</th>
                    <th>Transaction</th>
                    <th>Type</th>
                    <th>Utilisateur</th>
                    <th>Driver</th>
                    <th>Statut</th>
                    <th>Montant</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="log in logs" :key="log.id" :class="getRowClass(log.moov_money_status)">
                    <td>
                      <div class="d-flex flex-column">
                        <span class="fw-medium">{{ formatDate(log.created_at) }}</span>
                        <small class="text-muted">{{ formatTime(log.created_at) }}</small>
                      </div>
                    </td>
                    <td>
                      <Link :href="`/moov-money-transactions/${log.id}`" class="fw-medium text-primary">
                        {{ log.request_number }}
                      </Link>
                      <br>
                      <small class="text-muted">{{ log.id }}</small>
                    </td>
                    <td>
                      <span :class="log.moov_money_type === 'deposit' ? 'badge bg-success' : 'badge bg-info'">
                        <i :class="log.moov_money_type === 'deposit' ? 'bx bx-down-arrow-alt' : 'bx bx-up-arrow-alt'"></i>
                        {{ log.moov_money_type === 'deposit' ? 'Dépôt' : 'Retrait' }}
                      </span>
                    </td>
                    <td>
                      <div v-if="log.user_detail">
                        <div class="fw-medium">{{ log.user_detail.name }}</div>
                        <small class="text-muted">{{ log.user_detail.mobile }}</small>
                      </div>
                      <span v-else class="text-muted">N/A</span>
                    </td>
                    <td>
                      <div v-if="log.driver_detail">
                        <div class="fw-medium">{{ log.driver_detail.name }}</div>
                        <small class="text-muted">{{ log.driver_detail.mobile }}</small>
                      </div>
                      <span v-else class="text-muted">Non assigné</span>
                    </td>
                    <td>
                      <span :class="getStatusBadgeClass(log.moov_money_status)">
                        <i :class="getStatusIcon(log.moov_money_status)"></i>
                        {{ getStatusLabel(log.moov_money_status) }}
                      </span>
                    </td>
                    <td>
                      <div class="fw-medium">{{ formatMoney(log.moov_money_amount) }} XOF</div>
                      <small class="text-muted">
                        Commission: {{ formatMoney(log.moov_money_commission || 0) }} XOF
                      </small>
                    </td>
                    <td>
                      <div class="dropdown">
                        <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                          Actions
                        </button>
                        <ul class="dropdown-menu">
                          <li>
                            <Link :href="`/moov-money-transactions/${log.id}`" class="dropdown-item">
                              <i class="bx bx-show me-2"></i>Voir Détails
                            </Link>
                          </li>
                          <li v-if="canUpdateStatus(log.moov_money_status)">
                            <button @click="showUpdateStatusModal(log)" class="dropdown-item">
                              <i class="bx bx-edit me-2"></i>Changer Statut
                            </button>
                          </li>
                          <li>
                            <button @click="copyTransactionId(log.id)" class="dropdown-item">
                              <i class="bx bx-copy me-2"></i>Copier ID
                            </button>
                          </li>
                          <li><hr class="dropdown-divider"></li>
                          <li>
                            <button @click="retryTransaction(log)" class="dropdown-item text-warning">
                              <i class="bx bx-refresh me-2"></i>Réessayer
                            </button>
                          </li>
                        </ul>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <div v-if="pagination && pagination.last_page > 1" class="d-flex justify-content-between align-items-center mt-4">
              <div class="text-muted">
                Affichage de {{ pagination.from }} à {{ pagination.to }} sur {{ pagination.total }} entrées
              </div>
              <nav>
                <ul class="pagination pagination-sm mb-0">
                  <li class="page-item" :class="{ disabled: !pagination.prev_page_url }">
                    <button @click="changePage(pagination.current_page - 1)" class="page-link">Précédent</button>
                  </li>
                  <li 
                    v-for="page in paginationPages" 
                    :key="page" 
                    class="page-item" 
                    :class="{ active: page === pagination.current_page }"
                  >
                    <button @click="changePage(page)" class="page-link">{{ page }}</button>
                  </li>
                  <li class="page-item" :class="{ disabled: !pagination.next_page_url }">
                    <button @click="changePage(pagination.current_page + 1)" class="page-link">Suivant</button>
                  </li>
                </ul>
              </nav>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de mise à jour du statut -->
    <div class="modal fade" id="updateStatusModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Mettre à jour le statut</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="updateStatus">
              <div class="mb-3">
                <label class="form-label">Nouveau statut</label>
                <select v-model="statusUpdate.status" class="form-select" required>
                  <option value="pending">En attente</option>
                  <option value="accepted">Accepté</option>
                  <option value="processing">En cours</option>
                  <option value="completed">Complété</option>
                  <option value="failed">Échoué</option>
                  <option value="cancelled">Annulé</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Raison (optionnel)</label>
                <textarea v-model="statusUpdate.reason" class="form-control" rows="3" placeholder="Expliquez pourquoi vous changez ce statut..."></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
            <button @click="updateStatus" class="btn btn-primary" :disabled="updating">
              {{ updating ? 'Mise à jour...' : 'Mettre à jour' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link } from '@inertiajs/vue3';

export default {
  components: {
    Layout,
    PageHeader,
    Link,
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
          text: "Logs",
          active: true,
        },
      ],
      logs: [],
      pagination: null,
      filters: {
        period: '7',
        level: 'all',
        search: ''
      },
      loading: false,
      syncing: false,
      updating: false,
      autoRefresh: false,
      refreshInterval: null,
      statusUpdate: {
        transactionId: null,
        status: '',
        reason: ''
      }
    };
  },
  computed: {
    paginationPages() {
      if (!this.pagination) return [];
      const pages = [];
      const current = this.pagination.current_page;
      const last = this.pagination.last_page;
      
      for (let i = Math.max(1, current - 2); i <= Math.min(last, current + 2); i++) {
        pages.push(i);
      }
      return pages;
    }
  },
  mounted() {
    this.loadLogs();
  },
  beforeUnmount() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  },
  methods: {
    async loadLogs(page = 1) {
      this.loading = true;
      try {
        const params = {
          page,
          ...this.filters
        };
        
        const response = await axios.get('/moov-money-settings/logs', { params });
        this.logs = response.data.data;
        this.pagination = {
          current_page: response.data.current_page,
          last_page: response.data.last_page,
          from: response.data.from,
          to: response.data.to,
          total: response.data.total,
          prev_page_url: response.data.prev_page_url,
          next_page_url: response.data.next_page_url
        };
      } catch (error) {
        console.error('Erreur lors du chargement des logs:', error);
        this.$toast.error('Erreur lors du chargement des logs');
      } finally {
        this.loading = false;
      }
    },
    
    clearFilters() {
      this.filters = {
        period: '7',
        level: 'all',
        search: ''
      };
      this.loadLogs();
    },
    
    changePage(page) {
      if (page >= 1 && page <= this.pagination.last_page) {
        this.loadLogs(page);
      }
    },
    
    toggleAutoRefresh() {
      if (this.autoRefresh) {
        this.refreshInterval = setInterval(() => {
          this.loadLogs(this.pagination?.current_page || 1);
        }, 30000); // Actualiser toutes les 30 secondes
      } else {
        if (this.refreshInterval) {
          clearInterval(this.refreshInterval);
          this.refreshInterval = null;
        }
      }
    },
    
    async forceSync() {
      this.syncing = true;
      try {
        const response = await axios.post('/moov-money-settings/force-sync');
        
        if (response.data.success) {
          this.$toast.success(`Synchronisation terminée. ${response.data.synced_count} transactions mises à jour.`);
          this.loadLogs();
        } else {
          this.$toast.error('Erreur lors de la synchronisation: ' + response.data.message);
        }
      } catch (error) {
        console.error('Erreur lors de la synchronisation:', error);
        this.$toast.error('Erreur lors de la synchronisation');
      } finally {
        this.syncing = false;
      }
    },
    
    exportLogs() {
      const params = new URLSearchParams(this.filters).toString();
      window.location.href = `/moov-money-settings/logs/export?${params}`;
    },
    
    showUpdateStatusModal(transaction) {
      this.statusUpdate = {
        transactionId: transaction.id,
        status: transaction.moov_money_status,
        reason: ''
      };
      
      const modal = new bootstrap.Modal(document.getElementById('updateStatusModal'));
      modal.show();
    },
    
    async updateStatus() {
      this.updating = true;
      try {
        const response = await axios.post(`/moov-money-transactions/${this.statusUpdate.transactionId}/update-status`, {
          status: this.statusUpdate.status,
          reason: this.statusUpdate.reason
        });
        
        if (response.data.success) {
          this.$toast.success('Statut mis à jour avec succès');
          this.loadLogs();
          
          const modal = bootstrap.Modal.getInstance(document.getElementById('updateStatusModal'));
          modal.hide();
        }
      } catch (error) {
        console.error('Erreur lors de la mise à jour:', error);
        this.$toast.error('Erreur lors de la mise à jour du statut');
      } finally {
        this.updating = false;
      }
    },
    
    copyTransactionId(id) {
      navigator.clipboard.writeText(id).then(() => {
        this.$toast.success('ID copié dans le presse-papiers');
      });
    },
    
    async retryTransaction(transaction) {
      if (confirm('Êtes-vous sûr de vouloir réessayer cette transaction ?')) {
        try {
          const response = await axios.post(`/moov-money-transactions/${transaction.id}/retry`);
          
          if (response.data.success) {
            this.$toast.success('Transaction relancée avec succès');
            this.loadLogs();
          }
        } catch (error) {
          console.error('Erreur lors de la relance:', error);
          this.$toast.error('Erreur lors de la relance de la transaction');
        }
      }
    },
    
    canUpdateStatus(status) {
      return ['pending', 'processing', 'failed'].includes(status);
    },
    
    getRowClass(status) {
      const classes = {
        'failed': 'table-danger',
        'pending': 'table-warning',
        'processing': 'table-info',
        'completed': 'table-success'
      };
      return classes[status] || '';
    },
    
    getStatusBadgeClass(status) {
      const classes = {
        pending: 'badge bg-warning',
        accepted: 'badge bg-info',
        processing: 'badge bg-primary',
        completed: 'badge bg-success',
        failed: 'badge bg-danger',
        cancelled: 'badge bg-secondary'
      };
      return classes[status] || 'badge bg-secondary';
    },
    
    getStatusIcon(status) {
      const icons = {
        pending: 'bx bx-time',
        accepted: 'bx bx-check',
        processing: 'bx bx-loader-alt bx-spin',
        completed: 'bx bx-check-circle',
        failed: 'bx bx-x-circle',
        cancelled: 'bx bx-block'
      };
      return icons[status] || 'bx bx-help-circle';
    },
    
    getStatusLabel(status) {
      const labels = {
        pending: 'En attente',
        accepted: 'Accepté',
        processing: 'En cours',
        completed: 'Complété',
        failed: 'Échoué',
        cancelled: 'Annulé'
      };
      return labels[status] || status;
    },
    
    formatMoney(amount) {
      return new Intl.NumberFormat('fr-FR').format(amount || 0);
    },
    
    formatDate(date) {
      return new Date(date).toLocaleDateString('fr-FR');
    },
    
    formatTime(date) {
      return new Date(date).toLocaleTimeString('fr-FR');
    }
  }
};
</script>

<style scoped>
.table-responsive {
  max-height: 600px;
  overflow-y: auto;
}

.form-check-input:checked {
  background-color: #28a745;
  border-color: #28a745;
}

.badge {
  font-size: 0.75em;
}
</style>
