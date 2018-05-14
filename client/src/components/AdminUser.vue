<template>
  <div class="settings-page">
    <div class="container user-container">
      <div v-if="user">
        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <div class="back-icon" @click="goBack">
              <icon name="chevron-circle-left" scale="1.8"></icon>
            </div>
          </div>
          <div class="field-body">
            <div class="field">
              <label class="label title-label">User Profile</label>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Email</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.email">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">First Name</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.firstName">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Last Name</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.lastName">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Registered At</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.registered">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Status</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.status"
                  :class="{'has-text-danger': user.status == 'Inactive',
                           'has-text-warning': user.status == 'Verifying',
                           'has-text-success': user.status == 'Active'}">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal" v-if="user.status != 'Active' && user.verificationKey">
          <div class="field-label is-normal">
            <label class="label">Verification Link</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.verificationLink">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Country</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.country">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">State</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.state">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">City</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.city">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Affiliation</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.affiliation">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Employer</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.employer">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Title</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.title">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Purpose</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.purpose">
              </div>
            </div>
          </div>
        </div>

        <div class="field is-horizontal">
          <div class="field-label is-normal">
            <label class="label">Hear From</label>
          </div>
          <div class="field-body">
            <div class="field">
              <div class="control">
                <input class="input is-static" type="text" readonly v-model="user.hearFrom">
              </div>
            </div>
          </div>
        </div>

        <div class="spinner-container" v-if="waiting">
          <icon name="spinner" class="icon is-medium fa-spin"></icon>
        </div>
        <div v-if="error" class="notification is-danger">
          <button class="delete" @click="error=''"></button>
          {{error}}
        </div>
        <div v-if="success" class="notification is-success">
          <button class="delete" @click="success=''"></button>
          {{success}}
        </div>

        <div class="field is-horizontal">
          <div class="field-label">
            <!-- Left empty for spacing -->
          </div>
          <div class="field-body">
            <div class="field is-grouped">
              <div class="control" v-if="user.role == 'Normal' && user.status == 'Inactive'">
                <button class="button is-primary" @click="sendLink">
                  Send Verification Link
                </button>
              </div>
              <div class="control" v-if="user.role == 'Normal' && user.status == 'Verifying'">
                <button class="button is-primary" @click="sendLink">
                  Resend Verification Link
                </button>
              </div>
              <div class="control" v-if="user.role == 'Normal' && user.status == 'Active'">
                <button class="button is-danger" @click="deactivate">
                  Deactivate User
                </button>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <confirm-modal
      :opened="confirmModal.opened"
      :title="confirmModal.title"
      :message="confirmModal.message"
      :confirm-button="confirmModal.confirmButton"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>
  </div>
</template>

<script>
import DateForm from 'dateformat'
import ConfirmModal from './modals/ConfirmModal'

export default {
  name: 'admin-user',
  components: {
    ConfirmModal
  },
  data () {
    return {
      error: '',
      success: '',
      waiting: false,
      user: null,
      confirmModal: {
        opened: false,
        message: '',
        button: '',
        context: null
      },
    }
  },
  methods: {
    getUser () {
      this.waiting = true
      var userId = this.$route.params.userId
      this.$http.get(xHTTPx + '/get_user/' + userId).then((response) => {
        var resp = response.body
        this.user = resp
        var utcSeconds = this.user.createdTime
        var d = new Date(0)
        d.setUTCSeconds(utcSeconds)
        this.user.registered = DateForm(d)
        this.user.verificationLink = xHTTPx + '/verify_user/' + this.user.verificationKey
        this.waiting = false
      }, (response) => {
        this.error = 'Failed to get user: ' + JSON.stringify(response.body)
        this.waiting = false
      })
    },
    goBack () {
      this.$router.push('/admin')
    },
    sendLink () {
      var title = 'Send Verification Link'
      var message = "Are you sure to send the verification link to the user 's email box!"
      var confirmButton = 'Yes, send the link'
      var context = {callback: this.sendLinkConfirmed, args: []}
      this.openConfirmModal(title, message, confirmButton, context)
    },
    sendLinkConfirmed () {
      this.waiting = true
      this.error = ''
      this.success = ''
      var userId = this.$route.params.userId
      this.$http.post(xHTTPx + '/send_verification/' + userId).then((response) => {
        var resp = response.body
        if(resp.ok){
          this.error = ''
          this.user.status = 'Verifying'
          this.success = "The verification link has been sent to the user's email box."
        }else{
          this.error = "Failed to send the verification link"
          this.success = ''
        }
        this.waiting = false
      }, (response) => {
        this.error = 'Failed to send link: ' + JSON.stringify(response.body)
        this.success = ''
        this.waiting = false
      })
    },
    deactivate () {
      var title = 'Deactivate User Account'
      var message = "Are you sure to deactivate the user account: " + this.user.email + " !"
      var confirmButton = 'Yes, deactivate it'
      var context = {callback: this.deactivateConfirmed, args: []}
      this.openConfirmModal(title, message, confirmButton, context)
    },
    deactivateConfirmed () {
      this.waiting = true
      this.error = ''
      this.success = ''
      var userId = this.$route.params.userId
      this.$http.post(xHTTPx + '/deactivate_user/' + userId).then((response) => {
        var resp = response.body
        if(resp.ok){
          this.error = ''
          this.user.status = 'Inactive'
          this.user.verificationLink = ''
          this.success = "The user's account has been deactivated"
        }else{
          this.error = "Failed to deactivate the user account"
          this.success = ''
        }
        this.waiting = false
      }, (response) => {
        this.error = 'Failed to deactivate the user account: ' + JSON.stringify(response.body)
        this.success = ''
        this.waiting = false
      })
    },
    openConfirmModal (title, message, confirmButton, context) {
      this.confirmModal.title = title
      this.confirmModal.message = message
      this.confirmModal.confirmButton = confirmButton
      this.confirmModal.context = context
      this.confirmModal.opened = true
    },
    closeConfirmModal (result) {
      this.confirmModal.title = ''
      this.confirmModal.message = ''
      this.confirmModal.confirmButton = ''
      this.confirmModal.opened = false
      if(result && this.confirmModal.context){
        var context = this.confirmModal.context
        if(context.callback){
            context.callback.apply(this, context.args)
        }
      }
      this.confirmModal.context = null
    },
  },
  mounted () {
    this.getUser()
  }
}
</script>

<style lang="scss" scoped>

.user-container {
  margin-top: 30px;
  margin-bottom: 30px;
}

.back-icon {
  position: relative;
  top: -5px;
  cursor: pointer;
}

.title-label {
  font-size: 20px;
  text-decoration: underline;
}

.spinner-container {
  text-align: center;
}

</style>
