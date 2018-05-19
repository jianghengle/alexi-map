<template>
  <div class="modal"
      :class="{'is-active': opened}">
    <div class="modal-background"></div>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">Ask Question</p>
        <button class="delete" @click="close"></button>
      </header>
      <section class="modal-card-body modal-body">
        <div v-if="error" class="notification is-danger">
          <button class="delete" @click="error=''"></button>
          {{error}}
        </div>
        <div class="field">
          <label class="label">Subject</label>
          <div class="control">
            <input class="input" type="text" placeholder="Your question subject" v-model="subject">
          </div>
        </div>
        <div class="field">
          <label class="label">Question</label>
          <div class="control">
            <textarea class="textarea" rows="10" placeholder="Your question" v-model="question"></textarea>
          </div>
        </div>
      </section>
      <footer class="modal-card-foot">
        <a class="button is-danger" :class="{'is-loading': waiting}" :disabled="!canAsk" @click="askQuestion">Ask Question</a>
        <a class="button button-right" @click="close">Cancel</a> 
      </footer>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ask-question-modal',
  props: ['opened'],
  data () {
    return {
      error: '',
      waiting: false,
      subject: '',
      question: ''
    }
  },
  computed: {
    canAsk () {
      return this.subject.trim() && this.question.trim()
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-ask-question-modal')
    },
    askQuestion(){
      if(!this.canAsk){
        return
      }
      this.waiting = true
      var message = {subject: this.subject.trim(), content: this.question.trim()}
      this.$http.post(xHTTPx + '/add_question', message).then(response => {
        var resp = response.body
        this.waiting= false
        this.$emit('close-ask-question-modal', resp)
      }, response => {
        this.error = 'Failed to ask question: ' + JSON.stringify(response.body)
        this.waiting= false
      })
    }
  }
}
</script>

<style lang="scss" scoped>

.modal-body {
  color: black;
  font-size: 16px;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}
</style>