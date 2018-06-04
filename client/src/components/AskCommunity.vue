<template>
  <div>
    <div class="spinner-container" v-if="waiting">
      <icon name="spinner" class="icon is-medium fa-spin"></icon>
    </div>
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
    <div class="field">
      <p class="control has-icons-left is-expanded">
        <input class="input" type="text" placeholder="Search all content"
          @blur="searchQuestions" @keyup.enter="searchQuestions" v-model="questionFilter">
        <span class="icon is-small is-left">
          <icon name="search"></icon>
        </span>
      </p>
    </div>

    <div class="pages-row">
      <div class="question-count">{{filteredQuestions.length}} thread(s)</div>
      <div class="ask-button">
        <a class="button is-info" @click="askQuestionModal.opened = true">
          Ask New Question
        </a>
      </div>
      <div class="pages" v-if="filteredQuestions.length">
        <ul class="pagination-list page-numbers">
          <li class="page-number">
            <a class="pagination-link" :disabled="pageNum <= 1" @click="pageQuestions(1)">P1</a>
          </li>
          <li class="page-number">
            <a class="pagination-link" :disabled="pageNum <= 1" @click="pageQuestions(pageNum - 1)"><icon name="chevron-left"></icon></a>
          </li>
          <li class="page-number">
            <a class="pagination-link is-current">{{currentPage}}</a>
          </li>
          <li class="page-number">
            <a class="pagination-link" :disabled="pageNum >= AllPages" @click="pageQuestions(pageNum + 1)"><icon name="chevron-right"></icon></a>
          </li>
          <li class="page-number">
            <a class="pagination-link" :disabled="pageNum >= AllPages" @click="pageQuestions(AllPages)">P{{AllPages}}</a>
          </li>
        </ul>
      </div>
    </div>

    <div v-if="pagedQuestions.length">
      <div v-for="q in pagedQuestions" :key="'q-' + q.id" class="question-container">
        <a v-if="role == 'Admin'" class="button delete delete-question-button" @click="deleteQuestion(q)"></a>

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
              <div class="column is-10 answer-content-container">
                <a v-if="a.userId == userId && !a.editing" class="button delete delete-answer-button" @click="deleteAnswer(q, a)"></a>
                <a v-if="a.userId == userId && !a.editing" class="edit-button" @click="editAnswer(a)">
                  <icon name="pencil-square" scale="1.3"></icon>
                </a>
                <pre v-if="!a.editing" class="answer-content" :id="'a-pre-' + a.id">{{a.content}}</pre>
                <textarea v-if="a.editing" class="textarea edit-content" placeholder="Your answer here"
                  :style="{'height': a.height + 'px'}"
                  v-model="a.editContent">
                </textarea>
              </div>
              <div class="column is-2">
                <div>{{a.user ? a.user.name : 'Anonymous'}}</div>
                <div class="gray-font">{{a.createdAt}}</div>
                <div v-if="a.editing">
                  <a class="button is-danger side-button" :class="{'is-loading': a.waiting}"
                    :disabled="a.content == a.editContent"
                    @click="updateAnswer(a)">
                    Update
                  </a>
                </div>
                <div v-if="a.editing"><a class="button side-button" @click="a.editing = false">Cancel</a></div>
              </div>
            </div>
          </div>

          <div v-if="q.replying" class="columns new-reply-container">
            <div class="column is-10">
              <div class="field">
                <div class="control new-reply-textarea">
                  <textarea class="textarea" placeholder="Your reply here" v-model="q.newReply"></textarea>
                </div>
              </div>
            </div>
            <div class="column is-2">
              <div>{{username}}</div>
              <div>
                <a class="button is-danger side-button" :class="{'is-loading': q.waiting}" :disabled="!q.newReply"
                  @click="replyQuestion(q)">
                  Reply
                </a>
              </div>
              <div><a class="button side-button" @click="q.replying = false">Cancel</a></div>
            </div>
          </div>

          <div class="buttons-row" v-if="token && !q.replying">
            <div class="field is-grouped">
              <p class="control">
                <a class="button is-info" @click="q.replying = true">
                  New Reply
                </a>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <ask-question-modal
      :opened="askQuestionModal.opened"
      @close-ask-question-modal="closeAskQuestionModal">
    </ask-question-modal>

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
import AskQuestionModal from './modals/AskQuestionModal'
import ConfirmModal from './modals/ConfirmModal'

export default {
  name: 'ask-community',
  components: {
    AskQuestionModal,
    ConfirmModal
  },
  data () {
    return {
      error: '',
      waiting: false,
      questions: [],
      askQuestionModal: {
        opened: false
      },
      confirmModal: {
        opened: false,
        message: '',
        button: '',
        context: null
      },
      questionFilter: '',
      filteredQuestions: [],
      pageSize: 5,
      pageNum: 1,
      pagedQuestions: []
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    userId () {
      return this.token ? this.$store.state.user.userId : null
    },
    role () {
      return this.token ? this.$store.state.user.role : null
    },
    username () {
      if(!this.token){
        return ""
      }
      var firstName = this.$store.state.user.firstName
      var lastName = this.$store.state.user.lastName
      return firstName + '.' + lastName
    },
    currentPage () {
      var start = (this.pageNum - 1) * this.pageSize + 1
      var end = this.pageNum * this.pageSize
      if(end > this.filteredQuestions.length){
        end = this.filteredQuestions.length
      }
      return start + ' ~ ' + end
    },
    AllPages () {
      return Math.ceil(this.filteredQuestions.length / this.pageSize)
    }
  },
  methods: {
    pageQuestions (num) {
      if(num){
        if(num < 1){
          this.pageNum = 1
        }else if(num > this.AllPages){
          this.pageNum = this.AllPages
        }else{
          this.pageNum = num
        }
      }
      var start = (this.pageNum - 1) * this.pageSize
      var end = this.pageNum * this.pageSize
      this.pagedQuestions = this.filteredQuestions.slice(start, end)
    },
    searchQuestions () {
      this.filterQuestions()
      this.pageQuestions(1)
    },
    filterQuestions () {
      if(!this.questionFilter){
        this.filteredQuestions = this.questions.slice()
        return
      }
      var questionFilter = this.questionFilter
      this.filteredQuestions = this.questions.filter(function(q){
        if(q.subject.includes(questionFilter)){
          return true
        }
        if(q.content.includes(questionFilter)){
          return true
        }
        for(var i=0;i<q.answers.length;i++){
          var a = q.answers[i]
          if(a.content.includes(questionFilter)){
            return true
          }
        }
        return false
      })
    },
    editAnswer (a) {
      a.height = document.getElementById('a-pre-' + a.id).offsetHeight
      a.editing = true
    },
    updateAnswer (a) {
      if(a.content == a.editContent)
        return

      a.waiting = true
      var message = {answerId: a.id, content: a.editContent}
      this.$http.post(xHTTPx + '/update_answer', message).then(response => {
        if(response.body.ok){
          a.content = a.editContent
          a.editing = false
        }
        a.waiting = false
      }, response => {
        a.waiting= false
      })
    },
    deleteAnswer (q, a) {
      var title = 'Delete Answer'
      var message = 'Are you sure to delete the answer to the question "' + q.subject + '"?'
      var confirmButton = 'Yes, delete it.'
      var context = {callback: this.deleteAnswerConfirmed, args: [q, a]}
      this.openConfirmModal(title, message, confirmButton, context)
    },
    deleteAnswerConfirmed (q, a) {
      var message = {answerId: a.id}
      this.$http.post(xHTTPx + '/delete_answer', message).then(response => {
        if(response.body.ok){
          var index = -1
          for(var i=0;i<q.answers.length;i++){
            if(q.answers[i].id == a.id){
              index = i
              break
            }
          }
          if(index >= 0){
            q.answers.splice(index, 1)
          }
        }
      })
    },
    replyQuestion (q) {
      if(!q.newReply) return

      q.waiting = true
      var message = {questionId: q.id, content: q.newReply}
      this.$http.post(xHTTPx + '/add_answer', message).then(response => {
        var resp = response.body
        q.waiting= false
        var a = resp.answer
        a.createdAt = this.makeTimeLabel(a.created)
        a.user = resp.user
        a.editing = false
        a.editContent = a.content
        a.waiting = false
        a.height = 0
        q.answers.push(a)
        q.replying = false
        q.newReply = ''
      }, response => {
        q.waiting= false
      })
    },
    deleteQuestion (q) {
      var title = 'Delete Question'
      var message = 'Are you sure to delete the question "' + q.subject + '" and ALL its answers?'
      var confirmButton = 'Yes, delete it.'
      var context = {callback: this.deleteQuestionConfirmed, args: [q]}
      this.openConfirmModal(title, message, confirmButton, context)
    },
    deleteQuestionConfirmed (q) {
      var message = {questionId: q.id}
      this.$http.post(xHTTPx + '/delete_question', message).then(response => {
        if(response.body.ok){
          var index = -1
          for(var i=0;i<this.questions.length;i++){
            if(this.questions[i].id == q.id){
              index = i
              break
            }
          }
          if(index >= 0){
            this.questions.splice(index, 1)
            this.filterQuestions()
            this.pageQuestions()
          }
        }
      })
    },
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
          a.editing = false
          a.editContent = a.content
          a.waiting = false
          a.height = 0
          if(!q.answers) q.answers = []
          q.answers.push(a)
        })
        questions = Object.values(questions)
        questions.forEach(function(q){
          q.createdAt = vm.makeTimeLabel(q.created)
          q.user = users[q.userId]
          q.open = false
          q.replying = false
          q.newReply = ''
          q.waiting = false
          if(!q.answers) q.answers = []
          q.answers.sort(function(a, b){
            return a.created - b.created
          })
        })
        questions.sort(function(a, b){
          return b.created - a.created
        })
        this.questions = questions
        this.filterQuestions()
        this.pageQuestions()
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
    },
    closeAskQuestionModal (resp) {
      if(resp){
        var q = resp.question
        q.answers = []
        q.user = resp.user
        q.createdAt = this.makeTimeLabel(q.created)
        q.open = false
        q.replying = false
        q.newReply = ''
        q.waiting = false
        this.questions.unshift(q)
        this.filterQuestions()
        this.pageQuestions(1)
      }
      this.askQuestionModal.opened = false
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
    }
  },
  mounted () {
    this.getQuestions()
  }
}
</script>

<style lang="scss" scoped>

.pages-row {
  margin-top: -10px;
  padding-bottom: 5px;

  .question-count {
    color: gray;
    font-size: 14px;
    float: left;
    padding-top: 10px;
    padding-right: 15px;
  }

  .ask-button {
    float: right;
    padding-top: 3px;
  }

  .pages{
    display: inline-block;

    .page-numbers {
      margin-top: 0px;
      margin-left: 0px;
      list-style-type: none;

      .page-number {
        margin-top: 0px!important;
      }
    }
  }
}

.gray-font {
  color: gray;
  font-size: 14px;
}

.delete-question-button {
  position: absolute;
  top: 10px;
  right: 15px;
}

.delete-answer-button {
  position: absolute;
  top: 12px;
  right: 12px;
}

.edit-button {
  position: absolute;
  top: 12px;
  right: 35px;
  color: rgba(10, 10, 10, 0.2);
}

.edit-button:hover {
  color: rgba(10, 10, 10, 0.3);
}

.question-container {
  border: 1px solid #dbdbdb;
  border-width: 0 0 1px;
  padding: 0.5em 0.75em;
  position: relative;

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
    background-color: hsl(204, 86%, 93%);
  }

  .question-answers-block {
    margin-top: 10px;
    margin-bottom: 10px;

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
      .answer-content-container {
        position: relative;
        padding-left: 40px;

        .answer-content {
          font-family: Futura-pt,Futura PT,Trebuchet MS,Arial,sans-serif;
          white-space: pre-line;
          border-radius: 5px;
        }

        .edit-content {
          min-height: 140px;
        }
      }
    }

    .new-reply-container {
      .new-reply-textarea{
        padding-left: 35px;
      }
      .new-reply-buttons {

      }
    }

    .buttons-row {
      margin-top: 12px;
      margin-left: 35px;
    }
  }
}

.side-button {
  margin-top: 10px;
}


</style>
