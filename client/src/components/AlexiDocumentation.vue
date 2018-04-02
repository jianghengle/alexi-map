<template>
  <div class="login-page">
    <div class="container">
      <div class="content text-content">
        <h4 class="p-header">Operational ET Determinations in the MENA Region for ESI and Water Productivity</h4>
        <iframe :src="iframeSource" style="width:1000px; height:1000px;" frameborder="0"></iframe>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-documentation',
  data () {
    return {
      iframeSource: 'https://docs.google.com/gview?embedded=true&url=' + xHTTPx + '/static/GloDET_Training.pdf',
    }
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

</style>
