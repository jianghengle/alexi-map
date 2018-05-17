<template>
  <div class="">
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="field is-grouped">
      <p class="control has-icons-left is-expanded">
        <input class="input" type="text" placeholder="Search all content">
        <span class="icon is-small is-left">
          <icon name="search"></icon>
        </span>
      </p>
      <p class="control">
        <a class="button is-info">
          Ask New Question
        </a>
      </p>
    </div>

    <div v-if="questions.length">
      <div v-for="q in questions" :key="'q-' + q.id" class="question-container">
        <a class="button delete delete-button"></a>
        <div class="columns question-header" @click="q.open = !q.open">
          <div class="column is-9">
            <div class="question-icon"><icon name="comments" class="icon has-text-info"></icon></div>
            <div class="question-subject">{{q.subject}}</div>
          </div>
          <div class="column is-1">
            {{q.answers.length}} <span class="gray-font">replies</span>
          </div>
          <div class="column is-2">
            <div>{{q.user ? q.user.name : 'Anonymous'}}</div>
            <div class="gray-font">{{q.createdAt}}</div>
          </div>
        </div>
        <div v-if="q.open" class="question-answers-block">
          <div class="columns question-content-container">
            <pre class="column is-10 question-content">{{q.content}}</pre>
          </div>
          <div v-for="a in q.answers" :key="'a-' + a.id">
            <div class="columns answer-container">
              <div class="column is-10">
                <pre class="answer-content">{{a.content}}</pre>
              </div>
              <div class="column is-2">
                <div>{{a.user ? a.user.name : 'Anonymous'}}</div>
                <div class="gray-font">{{a.createdAt}}</div>
              </div>
            </div>
          </div>
          <div class="buttons-row">
            <div class="field is-grouped">
              <p class="control">
                <a class="button is-info">
                  New Reply
                </a>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-else>No question posted Yet...</div>

    

  </div>
</template>

<script>
import DateForm from 'dateformat'

export default {
  name: 'ask-community',
  data () {
    return {
      error: '',
      waiting: false,
      questions: []
    }
  },
  methods: {
    getQuestions () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_questions').then((response) => {
        var resp = response.body
        var questions = this.makeIdMap(resp.questions)
        var users = this.makeIdMap(resp.users)
        var vm = this
        resp.answers.forEach(function(a){
          var q = questions[a.questionId]
          a.createdAt = vm.makeTimeLabel(a.created)
          a.user = users[a.userId]
          if(!q.answers) q.answers = []
          q.answers.push(a)
        })
        questions = Object.values(questions)
        questions.forEach(function(q){
          q.createdAt = vm.makeTimeLabel(q.created)
          q.user = users[q.userId]
          q.open = false
          if(!q.answers) q.answers = []
          q.answers.sort(function(a, b){
            return a.created - b.created
          })
        })
        questions.sort(function(a, b){
          return b.created - a.created
        })
        this.questions = questions
        console.log(this.questions)
        this.waiting = false
      }, (response) => {
        this.error = 'failed to get all the questions'
        this.waiting = false
      })
    },
    makeIdMap (arr) {
      var m = {}
      for(var i=0;i<arr.length;i++){
        var obj = arr[i]
        m[obj.id] = obj
      }
      return m
    },
    makeTimeLabel (utcSeconds) {
      var d = new Date(0)
      d.setUTCSeconds(utcSeconds)
      return DateForm(d, 'yyyy-mm-dd HH:MM')
    }
  },
  mounted () {
    this.getQuestions()
  }
}
</script>

<style lang="scss" scoped>

.gray-font {
  color: gray;
  font-size: 14px;
}

.question-container {
  border: 1px solid #dbdbdb;
  border-width: 0 0 1px;
  padding: 0.5em 0.75em;
  position: relative;

  .delete-button {
    position: absolute;
    top: 5px;
    right: 0px;
  }

  .question-header {
    cursor: pointer;

    .question-icon {
      float: left;
    }

    .question-subject {
      font-weight: bold;
      padding-left: 35px;
    }
  }

  .question-header:hover {
    background-color: #fafafa;
  }

  .question-answers-block {
    margin-top: 10px;
    margin-bottom: 5px;

    .question-content-container {

      .question-content {
        background-color: white;
        font-family: Futura-pt,Futura PT,Trebuchet MS,Arial,sans-serif;
        padding-top: 0px;
        padding-bottom: 0px;
        padding-left: 47px;
        padding-right: 0px;
        white-space: pre-line;
      }
    }

    .answer-container {
      .answer-content {
        font-family: Futura-pt,Futura PT,Trebuchet MS,Arial,sans-serif;
        white-space: pre-line;
        border-radius: 5px;
        margin-left: 35px;
      }
    }

    .buttons-row {
      margin-top: 12px;
      margin-left: 35px;
    }
  }
}




</style>
