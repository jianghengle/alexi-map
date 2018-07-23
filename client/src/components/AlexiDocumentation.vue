<template>
  <div class="login-page">
    <div class="container">
      <div class="content text-content" id="the-container">
        <h4 class="p-header">Operational ET Determinations in the MENA Region for ESI and Water Productivity
          <a href="static/GloDET_Training.pdf" class="button is-text" download>link</a>
        </h4>
        <canvas id="the-canvas"></canvas>
        <div class="field has-addons has-addons-centered page-buttons">
          <p class="control">
            <a class="button is-medium" @click="previousPage" :disabled="page == 1 || rendering">
              <icon name="chevron-left"></icon>
            </a>
          </p>
          <p class="control">
            <input class="input is-medium page-input" type="text" placeholder="Page Number" v-model="pageLabel" @blur="setPage" @keyup.enter="setPage">
          </p>
          <p class="control">
            <a class="button is-medium" @click="nextPage" :disabled="!numPages || page == numPages || rendering">
              <icon name="chevron-right"></icon>
            </a>
          </p>
        </div>
      </div>
      <div class="content text-content">
        <h4 class="p-header">GloDET Quick Start Guide
          <a href="static/GloDET Quick Start Guide.pdf" class="button is-text" download>link</a>
        </h4>
        <div class="pdf-container">
          <iframe class="doc" :src="iframeSource"></iframe>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import pdfjsLib from 'pdfjs-dist'


export default {
  name: 'alexi-documentation',
  data () {
    return {
      pdf: null,
      page: 1,
      numPages: null,
      rendering: false,
      timeoutId: null,
      pageLabel: '',
      iframeSource: 'https://docs.google.com/gview?url=' + xHTTPx + '/static/GloDET Quick Start Guide.pdf' + '&embedded=true'
    }
  },
  watch: {
    page: function (val) {
      this.pageLabel = this.page + '/' + this.numPages
    },
    numPages: function (val) {
      this.pageLabel = this.page + '/' + this.numPages
    },
  },
  methods: {
    renderPage () {
      var vm = this
      vm.rendering = true
      vm.pdf.getPage(vm.page).then(function(page) {
        var container = document.getElementById('the-container')
        var canvas = document.getElementById('the-canvas')
        var context = canvas.getContext('2d')

        var viewport = page.getViewport(1)
        var scale = container.clientWidth / viewport.width

        viewport = page.getViewport(scale)
        canvas.height = viewport.height
        canvas.width = viewport.width

        var renderContext = {
          canvasContext: context,
          viewport: viewport
        }

        page.render(renderContext).then(function(){
          vm.rendering = false
        })
      })
    },
    handleResize () {
      var vm = this
      if(!vm.timeoutId){
        vm.timeoutId = setTimeout(function(){
          if(!vm.rendering){
            vm.renderPage()
          }
          vm.timeoutId = null
        }, 500)
      }
    },
    previousPage () {
      if(this.page == 1 || this.rendering){
        return
      }
      this.page -= 1
      this.renderPage()
    },
    nextPage () {
      if(!this.numPages || this.page == this.numPages || this.rendering){
        return
      }
      this.page += 1
      this.renderPage()
    },
    setPage () {
      var page = parseInt(this.pageLabel)
      if(isNaN(page) || page < 1 || !this.numPages || page > this.numPages || this.rendering || page == this.page){
        this.pageLabel = this.page + '/' + this.numPages
      }else{
        this.page = page
        this.pageLabel = this.page + '/' + this.numPages
        this.renderPage()
      }
    }
  },
  mounted () {
    var vm = this
    pdfjsLib.getDocument('static/GloDET_Training.pdf').then(function(pdf) {
      vm.pdf = pdf
      vm.numPages = pdf.numPages
      vm.renderPage()
      window.addEventListener('resize', vm.handleResize)
    })
  },
  beforeDestroy () {
    window.removeEventListener('resize', this.handleResize)
  }
}
</script>

<style lang="scss" scoped>

.p-header{
  font-weight: bold;
  margin-bottom: 0.5em;
  color: #05485A;
}

.text-content {
  margin-bottom: 30px;
}

.page-buttons {
  margin-top: 10px;
}

.page-input {
  width: 80px;
}

.pdf-container {
  width: 100%;
  height: 1000px;
}

.doc {
  width: 100%;
  height: 1000px;
}
</style>
