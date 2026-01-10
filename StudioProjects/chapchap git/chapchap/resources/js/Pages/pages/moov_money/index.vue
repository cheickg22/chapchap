<template>
  <Layout>
    <PageHeader :title="$t('moov-money-dashboard')" :items="items" />
    
    <!-- Statistiques Principales -->
    <div class="row mb-4">
      <div class="col-xl-3 col-md-6">
        <div class="card card-animate">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="flex-grow-1 overflow-hidden">
                <p class="text-uppercase fw-medium text-muted text-truncate mb-0">Total Transactions</p>
              </div>
            </div>
            <div class="d-flex align-items-end justify-content-between mt-4">
              <div>
                <h4 class="fs-22 fw-semibold ff-secondary mb-4">
                  <span class="counter-value">{{ stats.total || 0 }}</span>
                </h4>
                <p class="text-muted mb-0">
                  <span class="text-success fw-medium">
                    <i class="bx bx-trending-up align-middle"></i> +{{ stats.growth_rate || 0 }}%
                  </span>
                  ce mois
                </p>
              </div>
              <div class="avatar-sm flex-shrink-0">
                <span class="avatar-title bg-soft-primary rounded fs-3">
                  <i class="bx bx-money text-primary"></i>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-xl-3 col-md-6">
        <div class="card card-animate">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="flex-grow-1 overflow-hidden">
                <p class="text-uppercase fw-medium text-muted text-truncate mb-0">Montant Total</p>
              </div>
            </div>
            <div class="d-flex align-items-end justify-content-between mt-4">
              <div>
                <h4 class="fs-22 fw-semibold ff-secondary mb-4">
                  {{ formatMoney(stats.total_amount || 0) }} XOF
                </h4>
                <p class="text-muted mb-0">
                  <span class="text-success fw-medium">
                    <i class="bx bx-trending-up align-middle"></i> +{{ stats.amount_growth || 0 }}%
                  </span>
                  ce mois
                </p>
              </div>
              <div class="avatar-sm flex-shrink-0">
                <span class="avatar-title bg-soft-success rounded fs-3">
                  <i class="bx bx-wallet text-success"></i>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-xl-3 col-md-6">
        <div class="card card-animate">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="flex-grow-1 overflow-hidden">
                <p class="text-uppercase fw-medium text-muted text-truncate mb-0">Commissions</p>
              </div>
            </div>
            <div class="d-flex align-items-end justify-content-between mt-4">
              <div>
                <h4 class="fs-22 fw-semibold ff-secondary mb-4">
                  {{ formatMoney(stats.total_commission || 0) }} XOF
                </h4>
                <p class="text-muted mb-0">
                  Taux moyen: {{ stats.avg_commission_rate || 0 }}%
                </p>
              </div>
              <div class="avatar-sm flex-shrink-0">
                <span class="avatar-title bg-soft-info rounded fs-3">
                  <i class="bx bx-receipt text-info"></i>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-xl-3 col-md-6">
        <div class="card card-animate">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="flex-grow-1 overflow-hidden">
                <p class="text-uppercase fw-medium text-muted text-truncate mb-0">Taux de Réussite</p>
              </div>
            </div>
            <div class="d-flex align-items-end justify-content-between mt-4">
              <div>
                <h4 class="fs-22 fw-semibold ff-secondary mb-4">
                  {{ stats.success_rate || 0 }}%
                </h4>
                <p class="text-muted mb-0">
                  {{ stats.completed || 0 }} / {{ stats.total || 0 }} complétées
                </p>
              </div>
              <div class="avatar-sm flex-shrink-0">
                <span class="avatar-title bg-soft-warning rounded fs-3">
                  <i class="bx bx-check-circle text-warning"></i>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Graphiques et Analyses -->
    <div class="row mb-4">
      <!-- Graphique des Transactions par Jour -->
      <div class="col-xl-8">
        <div class="card">
          <div class="card-header">
            <div class="d-flex align-items-center">
              <h5 class="card-title mb-0 flex-grow-1">Évolution des Transactions</h5>
              <div class="flex-shrink-0">
                <select v-model="chartPeriod" @change="loadChartData" class="form-select form-select-sm">
                  <option value="7">7 derniers jours</option>
                  <option value="30">30 derniers jours</option>
                  <option value="90">90 derniers jours</option>
                </select>
              </div>
            </div>
          </div>
          <div class="card-body">
            <canvas ref="transactionChart" height="300"></canvas>
          </div>
        </div>
      </div>

      <!-- Répartition par Type -->
      <div class="col-xl-4">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">Répartition par Type</h5>
          </div>
          <div class="card-body">
            <canvas ref="typeChart" height="300"></canvas>
          </div>
        </div>
      </div>
    </div>

    <!-- Répartition par Statut et Top Drivers -->
    <div class="row mb-4">
      <!-- Répartition par Statut -->
      <div class="col-xl-4">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">Répartition par Statut</h5>
          </div>
          <div class="card-body">
            <canvas ref="statusChart" height="250"></canvas>
          </div>
        </div>
      </div>

      <!-- Top Drivers -->
      <div class="col-xl-8">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">Top Drivers Moov Money</h5>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-hover table-nowrap align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Driver</th>
                    <th>Transactions</th>
                    <th>Montant Total</th>
                    <th>Commission</th>
                    <th>Taux de Réussite</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(driver, index) in topDrivers" :key="driver.driver_id">
                    <td>
                      <div class="d-flex align-items-center">
                        <div class="flex-shrink-0 me-2">
                          <div class="avatar-xs">
                            <div class="avatar-title rounded-circle bg-soft-primary text-primary">
                              {{ index + 1 }}
                            </div>
                          </div>
                        </div>
                        <div class="flex-grow-1">
                          <h6 class="mb-0">{{ driver.driver_detail?.name || 'N/A' }}</h6>
                          <p class="text-muted mb-0">{{ driver.driver_detail?.mobile || 'N/A' }}</p>
                        </div>
                      </div>
                    </td>
                    <td>{{ driver.transaction_count }}</td>
                    <td>{{ formatMoney(driver.total_amount) }} XOF</td>
                    <td>{{ formatMoney(driver.total_commission) }} XOF</td>
                    <td>
                      <span class="badge bg-success">{{ driver.success_rate || 0 }}%</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertes et Notifications -->
    <div class="row mb-4">
      <div class="col-xl-6">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">Transactions en Attente</h5>
          </div>
          <div class="card-body">
            <div v-if="pendingTransactions.length === 0" class="text-center text-muted py-4">
              <i class="bx bx-check-circle fs-1"></i>
              <p class="mt-2">Aucune transaction en attente</p>
            </div>
            <div v-else>
              <div v-for="transaction in pendingTransactions" :key="transaction.id" 
                   class="d-flex align-items-center border-bottom pb-2 mb-2">
                <div class="flex-grow-1">
                  <h6 class="mb-1">{{ transaction.request_number }}</h6>
                  <p class="text-muted mb-0">{{ transaction.user_detail?.name }} - {{ formatMoney(transaction.moov_money_amount) }} XOF</p>
                </div>
                <div class="flex-shrink-0">
                  <Link :href="`/moov-money-transactions/${transaction.id}`" class="btn btn-sm btn-outline-primary">
                    Voir
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-xl-6">
        <div class="card">
          <div class="card-header">
            <h5 class="card-title mb-0">Transactions Échouées Récentes</h5>
          </div>
          <div class="card-body">
            <div v-if="failedTransactions.length === 0" class="text-center text-muted py-4">
              <i class="bx bx-check-circle fs-1"></i>
              <p class="mt-2">Aucune transaction échouée récente</p>
            </div>
            <div v-else>
              <div v-for="transaction in failedTransactions" :key="transaction.id" 
                   class="d-flex align-items-center border-bottom pb-2 mb-2">
                <div class="flex-grow-1">
                  <h6 class="mb-1">{{ transaction.request_number }}</h6>
                  <p class="text-muted mb-0">{{ transaction.user_detail?.name }} - {{ formatDate(transaction.created_at) }}</p>
                </div>
                <div class="flex-shrink-0">
                  <Link :href="`/moov-money-transactions/${transaction.id}`" class="btn btn-sm btn-outline-danger">
                    Analyser
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Mode Test Alert -->
    <div v-if="test_mode" class="alert alert-warning alert-dismissible fade show" role="alert">
      <i class="bx bx-test-tube me-2"></i>
      <strong>Mode Test Activé!</strong> Les transactions sont actuellement simulées. 
      <Link href="/settings/moov-money" class="alert-link">Configurer l'API Moov Money</Link>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  </Layout>
</template>

<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link } from '@inertiajs/vue3';
import Chart from 'chart.js/auto';

export default {
  components: {
    Layout,
    PageHeader,
    Link,
  },
  props: {
    stats: Object,
    test_mode: Boolean,
  },
  data() {
    return {
      items: [
        {
          text: "Dashboard",
          href: "/",
        },
        {
          text: "Moov Money Dashboard",
          active: true,
        },
      ],
      chartPeriod: '30',
      transactionChart: null,
      typeChart: null,
      statusChart: null,
      topDrivers: [],
      pendingTransactions: [],
      failedTransactions: [],
      chartData: {
        daily_stats: [],
        status_distribution: [],
      }
    };
  },
  mounted() {
    this.loadDashboardData();
    this.loadChartData();
    this.initializeCharts();
    
    // Actualiser les données toutes les 30 secondes
    setInterval(() => {
      this.loadDashboardData();
    }, 30000);
  },
  methods: {
    async loadDashboardData() {
      try {
        const response = await axios.get('/moov-money-transactions/statistics', {
          params: { period: this.chartPeriod }
        });
        
        this.topDrivers = response.data.top_drivers || [];
        this.chartData = response.data;
        
        // Charger les transactions en attente et échouées
        await this.loadPendingTransactions();
        await this.loadFailedTransactions();
        
        this.updateCharts();
      } catch (error) {
        console.error('Erreur lors du chargement des données:', error);
      }
    },
    
    async loadPendingTransactions() {
      try {
        const response = await axios.get('/moov-money-transactions/list', {
          params: { status: 'pending', per_page: 5 }
        });
        this.pendingTransactions = response.data.data || [];
      } catch (error) {
        console.error('Erreur lors du chargement des transactions en attente:', error);
      }
    },
    
    async loadFailedTransactions() {
      try {
        const response = await axios.get('/moov-money-transactions/list', {
          params: { status: 'failed', per_page: 5 }
        });
        this.failedTransactions = response.data.data || [];
      } catch (error) {
        console.error('Erreur lors du chargement des transactions échouées:', error);
      }
    },
    
    async loadChartData() {
      await this.loadDashboardData();
    },
    
    initializeCharts() {
      this.initTransactionChart();
      this.initTypeChart();
      this.initStatusChart();
    },
    
    initTransactionChart() {
      const ctx = this.$refs.transactionChart.getContext('2d');
      this.transactionChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: [],
          datasets: [{
            label: 'Transactions',
            data: [],
            borderColor: 'rgb(75, 192, 192)',
            backgroundColor: 'rgba(75, 192, 192, 0.1)',
            tension: 0.1
          }, {
            label: 'Montant (XOF)',
            data: [],
            borderColor: 'rgb(255, 99, 132)',
            backgroundColor: 'rgba(255, 99, 132, 0.1)',
            yAxisID: 'y1',
            tension: 0.1
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: {
              type: 'linear',
              display: true,
              position: 'left',
            },
            y1: {
              type: 'linear',
              display: true,
              position: 'right',
              grid: {
                drawOnChartArea: false,
              },
            }
          }
        }
      });
    },
    
    initTypeChart() {
      const ctx = this.$refs.typeChart.getContext('2d');
      this.typeChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
          labels: ['Dépôts', 'Retraits'],
          datasets: [{
            data: [0, 0],
            backgroundColor: ['#28a745', '#007bff']
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
        }
      });
    },
    
    initStatusChart() {
      const ctx = this.$refs.statusChart.getContext('2d');
      this.statusChart = new Chart(ctx, {
        type: 'pie',
        data: {
          labels: [],
          datasets: [{
            data: [],
            backgroundColor: [
              '#ffc107', // pending
              '#17a2b8', // accepted
              '#007bff', // processing
              '#28a745', // completed
              '#dc3545', // failed
            ]
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
        }
      });
    },
    
    updateCharts() {
      if (this.chartData.daily_stats) {
        // Mettre à jour le graphique des transactions
        const labels = this.chartData.daily_stats.map(stat => 
          new Date(stat.date).toLocaleDateString('fr-FR')
        );
        const counts = this.chartData.daily_stats.map(stat => stat.count);
        const amounts = this.chartData.daily_stats.map(stat => stat.amount);
        
        this.transactionChart.data.labels = labels;
        this.transactionChart.data.datasets[0].data = counts;
        this.transactionChart.data.datasets[1].data = amounts;
        this.transactionChart.update();
        
        // Mettre à jour le graphique par type
        const totalDeposits = this.chartData.daily_stats.reduce((sum, stat) => sum + stat.deposits, 0);
        const totalWithdrawals = this.chartData.daily_stats.reduce((sum, stat) => sum + stat.withdrawals, 0);
        
        this.typeChart.data.datasets[0].data = [totalDeposits, totalWithdrawals];
        this.typeChart.update();
      }
      
      if (this.chartData.status_distribution) {
        // Mettre à jour le graphique par statut
        const labels = this.chartData.status_distribution.map(stat => this.getStatusLabel(stat.moov_money_status));
        const data = this.chartData.status_distribution.map(stat => stat.count);
        
        this.statusChart.data.labels = labels;
        this.statusChart.data.datasets[0].data = data;
        this.statusChart.update();
      }
    },
    
    formatMoney(amount) {
      return new Intl.NumberFormat('fr-FR').format(amount || 0);
    },
    
    formatDate(date) {
      return new Date(date).toLocaleString('fr-FR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    
    getStatusLabel(status) {
      const labels = {
        pending: 'En attente',
        accepted: 'Accepté',
        processing: 'En cours',
        completed: 'Complété',
        failed: 'Échoué'
      };
      return labels[status] || status;
    }
  }
};
</script>

<style scoped>
.counter-value {
  display: inline-block;
}

.card-animate {
  transition: all 0.3s ease;
}

.card-animate:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}
</style>
