<template>
  <Layout>
    <PageHeader :title="$t('moov-money-transaction-details')" :items="items" />
    
    <div class="row">
      <div class="col-lg-12">
        <div class="card">
          <div class="card-header">
            <div class="d-flex align-items-center">
              <h5 class="card-title mb-0 flex-grow-1">
                Transaction #{{ transaction.request_number }}
              </h5>
              <div class="flex-shrink-0">
                <span :class="getStatusBadgeClass(transaction.moov_money_status)" class="badge fs-12">
                  {{ getStatusLabel(transaction.moov_money_status) }}
                </span>
              </div>
            </div>
          </div>
          
          <div class="card-body">
            <!-- Actions -->
            <div class="mb-4" v-if="canCancel || canDelete">
              <button 
                v-if="canCancel"
                @click="showCancelModal" 
                class="btn btn-warning me-2">
                <i class="bx bx-x-circle"></i> Annuler la Transaction
              </button>
              <button 
                v-if="canDelete"
                @click="confirmDelete" 
                class="btn btn-danger">
                <i class="bx bx-trash"></i> Supprimer
              </button>
            </div>

            <div class="row">
              <!-- Informations Générales -->
              <div class="col-md-6">
                <div class="card border">
                  <div class="card-header bg-light">
                    <h6 class="mb-0">Informations Générales</h6>
                  </div>
                  <div class="card-body">
                    <table class="table table-borderless mb-0">
                      <tbody>
                        <tr>
                          <td class="fw-medium">Type:</td>
                          <td>
                            <span :class="transaction.moov_money_type === 'deposit' ? 'badge bg-success' : 'badge bg-info'">
                              {{ transaction.moov_money_type === 'deposit' ? 'Dépôt' : 'Retrait' }}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-medium">Montant:</td>
                          <td class="text-primary fw-bold">{{ formatMoney(transaction.moov_money_amount) }} FCFA</td>
                        </tr>
                        <tr>
                          <td class="fw-medium">Commission:</td>
                          <td>{{ formatMoney(transaction.admin_commision) }} FCFA</td>
                        </tr>
                        <tr>
                          <td class="fw-medium">Téléphone:</td>
                          <td>{{ transaction.moov_money_phone }}</td>
                        </tr>
                        <tr>
                          <td class="fw-medium">Code Sécurité:</td>
                          <td>
                            <code class="fs-16">{{ transaction.moov_money_security_code }}</code>
                          </td>
                        </tr>
                        <tr v-if="transaction.moov_money_type === 'withdrawal'">
                          <td class="fw-medium">Code Validation:</td>
                          <td>
                            <code class="fs-16">{{ transaction.moov_money_validation_code }}</code>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-medium">Date Création:</td>
                          <td>{{ formatDate(transaction.created_at) }}</td>
                        </tr>
                        <tr v-if="transaction.completed_at">
                          <td class="fw-medium">Date Complétion:</td>
                          <td>{{ formatDate(transaction.completed_at) }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- Client -->
              <div class="col-md-6">
                <div class="card border">
                  <div class="card-header bg-light">
                    <h6 class="mb-0">Client</h6>
                  </div>
                  <div class="card-body">
                    <div class="d-flex align-items-center mb-3" v-if="transaction.userDetail">
                      <img 
                        :src="transaction.userDetail.profile_picture || '/images/default-avatar.png'" 
                        class="rounded-circle avatar-md me-3"
                        alt="Client">
                      <div>
                        <h6 class="mb-1">{{ transaction.userDetail.name }}</h6>
                        <p class="text-muted mb-0">{{ transaction.userDetail.mobile }}</p>
                        <p class="text-muted mb-0" v-if="transaction.userDetail.email">
                          {{ transaction.userDetail.email }}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Driver -->
                <div class="card border mt-3" v-if="transaction.driverDetail">
                  <div class="card-header bg-light">
                    <h6 class="mb-0">Agent</h6>
                  </div>
                  <div class="card-body">
                    <div class="d-flex align-items-center">
                      <img 
                        :src="transaction.driverDetail.user?.profile_picture || '/images/default-avatar.png'" 
                        class="rounded-circle avatar-md me-3"
                        alt="Agent">
                      <div>
                        <h6 class="mb-1">{{ transaction.driverDetail.user?.name }}</h6>
                        <p class="text-muted mb-0">{{ transaction.driverDetail.user?.mobile }}</p>
                        <p class="text-muted mb-0" v-if="transaction.driverDetail.user?.email">
                          {{ transaction.driverDetail.user?.email }}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Localisation -->
            <div class="row mt-3" v-if="transaction.requestPlace">
              <div class="col-12">
                <div class="card border">
                  <div class="card-header bg-light">
                    <h6 class="mb-0">Localisation</h6>
                  </div>
                  <div class="card-body">
                    <p class="mb-0">
                      <i class="bx bx-map text-primary"></i>
                      {{ transaction.requestPlace.pick_address }}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Transaction Moov Money -->
            <div class="row mt-3" v-if="transaction.moovMoneyTransaction">
              <div class="col-12">
                <div class="card border">
                  <div class="card-header bg-light">
                    <h6 class="mb-0">Détails Transaction Moov Money</h6>
                  </div>
                  <div class="card-body">
                    <table class="table table-borderless mb-0">
                      <tbody>
                        <tr>
                          <td class="fw-medium">Transaction ID:</td>
                          <td><code>{{ transaction.moovMoneyTransaction.transaction_id }}</code></td>
                        </tr>
                        <tr v-if="transaction.moovMoneyTransaction.voucher_code">
                          <td class="fw-medium">Voucher Code:</td>
                          <td><code>{{ transaction.moovMoneyTransaction.voucher_code }}</code></td>
                        </tr>
                        <tr>
                          <td class="fw-medium">Statut API:</td>
                          <td>{{ transaction.moovMoneyTransaction.status }}</td>
                        </tr>
                        <tr v-if="transaction.moovMoneyTransaction.response_message">
                          <td class="fw-medium">Message:</td>
                          <td>{{ transaction.moovMoneyTransaction.response_message }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <!-- Raison d'annulation -->
            <div class="row mt-3" v-if="transaction.is_cancelled && transaction.cancel_reason">
              <div class="col-12">
                <div class="alert alert-warning">
                  <h6 class="alert-heading">Transaction Annulée</h6>
                  <p class="mb-0">{{ transaction.cancel_reason }}</p>
                  <small class="text-muted">{{ formatDate(transaction.cancelled_at) }}</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Annulation -->
    <div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Annuler la Transaction</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Raison de l'annulation <span class="text-danger">*</span></label>
              <textarea 
                v-model="cancelReason" 
                class="form-control" 
                rows="3" 
                placeholder="Expliquez pourquoi vous annulez cette transaction..."
                maxlength="500"></textarea>
              <small class="text-muted">{{ cancelReason.length }}/500 caractères</small>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Fermer</button>
            <button type="button" class="btn btn-warning" @click="cancelTransaction" :disabled="!cancelReason.trim()">
              Annuler la Transaction
            </button>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script>
import { Link } from '@inertiajs/vue3';
import Layout from '@/Layouts/main.vue';
import PageHeader from '@/Components/page-header.vue';
import Swal from 'sweetalert2';
import { router } from '@inertiajs/vue3';

export default {
  components: {
    Link,
    Layout,
    PageHeader
  },
  props: {
    transaction: Object,
    firebaseConfig: Object,
    test_mode: Boolean
  },
  data() {
    return {
      items: [
        { text: 'ChapChap', href: '/' },
        { text: 'Transactions Moov Money', href: '/moov-money-transactions' },
        { text: 'Détails', active: true }
      ],
      cancelReason: ''
    };
  },
  computed: {
    canCancel() {
      return !this.transaction.is_completed && 
             !this.transaction.is_cancelled &&
             ['pending', 'accepted', 'processing'].includes(this.transaction.moov_money_status);
    },
    canDelete() {
      // Peut supprimer si annulée ou échouée
      return this.transaction.is_cancelled || 
             this.transaction.moov_money_status === 'failed';
    }
  },
  mounted() {
    console.log('Transaction loaded:', this.transaction);
    console.log('Can cancel:', this.canCancel);
    console.log('Can delete:', this.canDelete);
  },
  methods: {
    showCancelModal() {
      const modal = new bootstrap.Modal(document.getElementById('cancelModal'));
      modal.show();
    },
    async cancelTransaction() {
      if (!this.cancelReason.trim()) {
        Swal.fire('Erreur', 'Veuillez indiquer une raison', 'error');
        return;
      }

      try {
        const result = await Swal.fire({
          title: 'Confirmer l\'annulation?',
          text: 'Cette action est irréversible',
          icon: 'warning',
          showCancelButton: true,
          confirmButtonColor: '#f1b44c',
          cancelButtonColor: '#74788d',
          confirmButtonText: 'Oui, annuler',
          cancelButtonText: 'Non'
        });

        if (result.isConfirmed) {
          router.post(`/moov-money-transactions/cancel/${this.transaction.id}`, {
            reason: this.cancelReason
          }, {
            onSuccess: () => {
              Swal.fire('Annulée!', 'La transaction a été annulée', 'success');
              const modal = bootstrap.Modal.getInstance(document.getElementById('cancelModal'));
              modal.hide();
            },
            onError: (errors) => {
              Swal.fire('Erreur', errors.message || 'Une erreur est survenue', 'error');
            }
          });
        }
      } catch (error) {
        Swal.fire('Erreur', 'Une erreur est survenue', 'error');
      }
    },
    async confirmDelete() {
      console.log('confirmDelete called');
      console.log('Transaction ID:', this.transaction.id);
      
      try {
        const result = await Swal.fire({
          title: 'Supprimer cette transaction?',
          text: 'Cette action est irréversible',
          icon: 'warning',
          showCancelButton: true,
          confirmButtonColor: '#f06548',
          cancelButtonColor: '#74788d',
          confirmButtonText: 'Oui, supprimer',
          cancelButtonText: 'Annuler'
        });

        console.log('Swal result:', result);

        if (result.isConfirmed) {
          console.log('Deleting transaction...');
          
          router.delete(`/moov-money-transactions/delete/${this.transaction.id}`, {
            onSuccess: (response) => {
              console.log('Delete success:', response);
              Swal.fire('Supprimée!', 'La transaction a été supprimée', 'success')
                .then(() => {
                  router.visit('/moov-money-transactions');
                });
            },
            onError: (errors) => {
              console.error('Delete error:', errors);
              Swal.fire('Erreur', errors.message || 'Une erreur est survenue', 'error');
            }
          });
        }
      } catch (error) {
        console.error('confirmDelete error:', error);
        Swal.fire('Erreur', 'Une erreur est survenue: ' + error.message, 'error');
      }
    },
    formatMoney(amount) {
      return new Intl.NumberFormat('fr-FR').format(amount || 0);
    },
    formatDate(date) {
      if (!date) return 'N/A';
      return new Date(date).toLocaleString('fr-FR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    getStatusBadgeClass(status) {
      const classes = {
        pending: 'bg-warning',
        accepted: 'bg-info',
        processing: 'bg-primary',
        completed: 'bg-success',
        cancelled: 'bg-secondary',
        failed: 'bg-danger'
      };
      return classes[status] || 'bg-secondary';
    },
    getStatusLabel(status) {
      const labels = {
        pending: 'En attente',
        accepted: 'Accepté',
        processing: 'En cours',
        completed: 'Complété',
        cancelled: 'Annulé',
        failed: 'Échoué'
      };
      return labels[status] || status;
    }
  }
};
</script>

<style scoped>
.avatar-md {
  width: 60px;
  height: 60px;
  object-fit: cover;
}
</style>
