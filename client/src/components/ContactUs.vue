<template>
  <div class="contact-us-block">
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="field is-horizontal">
      <div class="field-label is-normal">
        <label class="label">Title</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input class="input" type="text" placeholder="Message title or subject" v-model="title">
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
            <input class="input" type="text" placeholder="Your first name" v-model="firstName">
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
            <input class="input" type="text" placeholder="Your last name" v-model="lastName">
          </div>
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
            <input class="input" type="email" placeholder="Your email" v-model="email">
          </div>
        </div>
      </div>
    </div>

    <div class="field is-horizontal">
      <div class="field-label is-normal">
        <label class="label">Organization</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <input class="input" type="text" placeholder="Your organization" v-model="organization">
          </div>
        </div>
      </div>
    </div>

    <div class="field is-horizontal">
      <div class="field-label is-normal">
        <label class="label">Message</label>
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <textarea class="textarea" rows="8" placeholder="Your message" v-model="message"></textarea>
          </div>
        </div>
      </div>
    </div>

    <div class="field is-horizontal">
      <div class="field-label is-normal">
        <label class="label">Human Verification</label>
      </div>
      <div class="field-body">
        <div class="field is-expanded">
          <div class="field has-addons">
            <p class="control">
              <img :src="verificationImage" alt="img">
            </p>
            <p class="control">
              <input class="input" type="text" v-model="c">
            </p>
          </div>
        </div>
      </div>
    </div>

    <div class="field is-horizontal">
      <div class="field-label">
        <!-- Left empty for spacing -->
      </div>
      <div class="field-body">
        <div class="field">
          <div class="control">
            <button class="button is-primary" :class="{'is-loading': waiting}" :disabled="!canSubmit" @click="submit">
              Submit
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'contact-us',
  data () {
    return {
      error: '',
      waiting: false,
      title: '',
      firstName: '',
      lastName: '',
      email: '',
      organization: '',
      message: '',
      a: '',
      t: '',
      b: '',
      c: '',
      verificationImage: ''
    }
  },
  computed: {
    canSubmit () {
      return this.title && this.firstName && this.lastName && this.email && this.organization && this.message && this.c
    }
  },
  methods: {
    makeVerificationImage () {
      var canvas = document.createElement('canvas')
      canvas.width  = 80
      canvas.height = 30

      var ctx=canvas.getContext("2d")
      ctx.font="20px Comic Sans MS"
      ctx.fillText(this.a + ' + ' + this.b + ' = ', 5, 27)
      this.verificationImage = canvas.toDataURL("image/png")
    },
    submit () {
      if(!this.canSubmit){
        return
      }
      this.waiting = true
      var content = 'Title: ' + this.title
      content += '\nFirst Name: ' + this.firstName
      content += '\nLast Name: ' + this.lastName
      content += '\nEmail: ' + this.email
      content += '\nOrganization: ' + this.organization
      content += '\nMessage:\n' + this.message
      var message = {content: content, a: this.a, b: this.b, c: this.c}
      this.$http.post(xHTTPx + '/contact_us', message).then(response => {
        var resp = response.body
        if(resp.ok){
          this.error = ''
        }else{
          this.error = 'Failed to send message'
        }
        this.waiting= false
      }, response => {
        this.error = 'Failed to send message: ' + JSON.stringify(response.body)
        this.waiting= false
      })
    }
  },
  mounted () {
    this.a = Math.floor(Math.random() * 3) + 3
    var milliseconds = (new Date()).getTime()
    this.t = Math.floor(milliseconds / 3600000) % 4
    this.b = this.a - this.t
    this.makeVerificationImage()
  }
}
</script>

<style lang="scss" scoped>

.contact-us-block {
  background-color: hsl(204, 86%, 83%);
  padding: 20px;
  border-radius: 5px;
}

</style>
