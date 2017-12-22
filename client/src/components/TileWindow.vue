<template>
  <div>
    <div class="box images-box" v-if="ready">
      <div class="columns image-options">
        <div class="column">
          <span class="image-input">
            <label class="image-input-label">Tile Size</label>
            <input class="input image-input-input" type="number" step="10" v-model.number="tileSize">
          </span>
        </div>
        <div class="column">
          <a class="button" :disabled="!preDate" @click="selectPreDate">
            <span class="icon is-small">
              <icon name="chevron-left"></icon>
            </span>
          </a>
          <datepicker
            wrapper-class="date-picker-wrapper"
            input-class="date-picker-input"
            format="yyyy-MM-dd"
            :value="date"
            :disabled="dateDisabled"
            v-on:selected="dateSelected">
          </datepicker>
          <a class="button" :disabled="!nextDate" @click="selectNextDate">
            <span class="icon is-small">
              <icon name="chevron-right"></icon>
            </span>
          </a>
        </div>
        <div class="column">
          <a class="button is-info" v-if="token" @click="downloadAll">
            Download All Tiles
          </a>
          <a class="button delete delete-button" @click="deleteWindow" v-if="wid != 0"></a>
        </div>
      </div>
      <div>
        <div class="image-container" 
          :style="{'height': height+'px', 'width': width+'px'}">
          <div v-for="(row, i) in images" :key="'row-' + i" class="image-row" :style="{'height': tileSize+'px'}">
            <a v-for="(cell, j) in row" :key="cell.id"
              :style="{'height': tileSize+'px', 'width': tileSize+'px'}"
              :class="{'tile-border': showGrid}"
              class="image-cell"
              :href="cell.tif">
              <img :src="cell.png"
                :height="tileSize"
                :width="tileSize"
                @click="clickTile(cell)">
            </a>
          </div>
          <div class="selection-on-image"
            v-show="showSelection"
            :style="{
              'top': selection.top + 'px',
              'left': selection.left + 'px',
              'height': selection.height + 'px',
              'width': selection.width + 'px'
            }">
          </div>
          <div class="color-band-container" :style="{'left': (width + 30) + 'px'}">
            <div class="color-band" :style="{'height': height + 'px'}">
            </div>
            <div class="color-annotation" v-for="(a, i) in colorAnnotations" :style="{'top': a.top + 'px'}">
              {{a.value}}&nbsp;<span v-if="i==0">mm/day</span>
            </div>
          </div>
          <div class="y-annotation" v-if="showGrid" v-for="a in yAnnotations" :style="{'top': a.top + 'px'}">
            <div class="y-label">
              <span v-if="a.label == '0'">&nbsp;</span>{{a.label}}
            </div>
          </div>
          <div class="x-annotation" v-if="showGrid" v-for="a in xAnnotations" :style="{'left': a.left + 'px'}">
            <div class="x-label">
              <span v-if="a.label == '0'">&nbsp;</span>{{a.label}}
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
import Datepicker from 'vuejs-datepicker'
import ConfirmModal from './modals/ConfirmModal'

export default {
  name: 'tile-window',
  components: {
    Datepicker,
    ConfirmModal
  },
  props: ['wid', 'mainDate', 'tileMatrix', 'selectionBounds', 'showGrid', 'showSelection', 'dateDisabled', 'mainTileSize'],
  data () {
    return {
      ready: false,
      date: new Date(),
      tileSize: 200,
      confirmModal: {
        opened: false,
        message: '',
        button: '',
        context: null
      },
    }
  },
  watch: {
    tileSize: function (val) {
      this.$emit('tile-window-tile-size-changed', this.tileSize)
    },
    mainTileSize: function (val) {
      this.tileSize = val
    },
    mainDate: function (val) {
      if(this.wid == 0){
        this.date = val
      }
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    height () {
      return this.tileSize * this.tileMatrix.length
    },
    width () {
      return this.tileSize * this.tileMatrix[0].length
    },
    year () {
      return this.date.getFullYear()
    },
    day () {
      return Math.ceil((this.date - new Date(this.year, 0, 1)) / 86400000)
    },
    dateCode () {
      return this.year + '_' + this.day
    },
    images () {
      var images = []
      for(var i=0;i<this.tileMatrix.length;i++){
        var row = this.tileMatrix[i]
        var imageRow = []
        for(var j=0;j<row.length;j++){
          var tile = row[j]
          var image = {}
          if(tile.tileNum){
            var tileCode = this.dateCode + '_' + tile.tileNum
            this.requestPng(this.year, this.day, tile.tileNum)
            image.png = this.$store.state.tiles.pngs[tileCode]
            if(this.token){
              this.requestTif(this.year, this.day, tile.tileNum)
              image.tif = this.$store.state.tiles.tifs[tileCode]
            }
          }
          imageRow.push(image)
        }
        images.push(imageRow)
      }
      return images
    },
    yearRange () {
      return this.$store.state.tiles.yearRange
    },
    daysInYears () {
      return this.$store.state.tiles.daysInYears
    },
    days () {
      return this.daysInYears[this.year]
    },
    preDate () {
      if(!this.yearRange || !this.daysInYears || !this.days)
        return null
      var index = this.days.indexOf(this.day)
      if(index <= 0)
        return null
      var day = this.days[index - 1]
      var ms = (new Date(this.year, 0, 1, 12)).getTime() + 86400000*(day-1)
      return new Date(ms)
    },
    nextDate () {
      if(!this.yearRange || !this.daysInYears || !this.days)
        return null
      var index = this.days.indexOf(this.day)
      if(index < 0 || index == this.days.length-1)
        return null
      var day = this.days[index + 1]
      var ms = (new Date(this.year, 0, 1, 12)).getTime() + 86400000*(day-1)
      return new Date(ms)
    },
    selection () {
      if(!this.tileSize)
        return {top: 0, left: 0, height: 0, width: 0}
      var topLeftTile = this.tileMatrix[0][0]
      var tlp2 = [topLeftTile.bounds.north, topLeftTile.bounds.west]
      var tlp1 = [this.selectionBounds.north, this.selectionBounds.west]
      var topLeftDist = this.distanceInPixel(tlp1, tlp2)

      var lastRow = this.tileMatrix[this.tileMatrix.length - 1]
      var bottomRightTile = lastRow[lastRow.length - 1]
      var brp1 = [this.selectionBounds.south, this.selectionBounds.east]
      var brp2 = [bottomRightTile.bounds.south, bottomRightTile.bounds.east]
      var bottomRightDist = this.distanceInPixel(brp1, brp2)

      var wholeHeight = this.tileMatrix.length * this.tileSize
      var height = wholeHeight - topLeftDist[1] - bottomRightDist[1]
      var wholeWidth = lastRow.length * this.tileSize
      var width = wholeWidth - topLeftDist[0] - bottomRightDist[0]
      return {top: topLeftDist[1], left: topLeftDist[0], height: height, width: width}
    },
    colorAnnotations () {
      if(!this.tileSize) return []
      var values = [7.5, 6.0, 4.5, 3.0, 1.5, 0.0]
      var intervel = this.height / (values.length - 1)
      var annotations = []
      for(var i=0;i<values.length;i++){
        var a = {value: values[i], top: Math.round(intervel * i - 10)}
        annotations.push(a)
      }
      return annotations
    },
    yAnnotations () {
      if(!this.tileMatrix ||!this.tileMatrix.length) return []
      if(!this.tileSize) return []
      var len = this.tileMatrix.length * 3
      var start = this.tileMatrix[0][0].bounds.north
      var intervel = this.tileSize / 3
      var yAnnotations = []
      for(var i=0;i<=len;i++){
        var lat = start - i * 5
        var label = lat >= 0 ? 'N' + lat : 'S' + (-lat)
        if(lat == 0) label = '0'
        var top = intervel * i - 1
        yAnnotations.push({label: label, top: top})
      }
      return yAnnotations
    },
    xAnnotations () {
      if(!this.tileMatrix ||!this.tileMatrix.length) return []
      if(!this.tileSize) return []
      var len = this.tileMatrix[0].length * 3
      var start = this.tileMatrix[0][0].bounds.west
      var intervel = this.tileSize / 3
      var xAnnotations = []
      for(var i=0;i<=len;i++){
        var lng = start + i * 5
        if(lng > 180){
          lng = -180 + (lng - 180)
        }
        var label = lng >= 0 ? 'E' + lng : 'W' + (-lng)
        if(lng == 0) label = '0'
        var left = intervel * i - 1
        xAnnotations.push({label: label, left: left})
      }
      return xAnnotations
    }
  },
  methods: {
    dateSelected (newDate) {
      this.date = newDate
      this.$emit('tile-window-date-changed', {wid: this.wid, date: newDate})
    },
    selectPreDate () {
      if(this.preDate){
        this.dateSelected(this.preDate)
      }
    },
    selectNextDate () {
      if(this.nextDate){
        this.dateSelected(this.nextDate)
      }
    },
    requestPng (year, day, tileNum) {
      var tileCode = this.dateCode + '_' + tileNum
      if(this.$store.state.tiles.pngs[tileCode] === undefined){
        this.$store.commit('tiles/setPng', {tileCode: tileCode, png: null})
        this.$http.get(xHTTPx + '/get_download_url/' + year + '/' + day + '/' + tileNum + '/png').then((response) => {
          var obj = {tileCode: tileCode, png: xHTTPx + response.body}
          this.$store.commit('tiles/setPng', obj)
        }, (response) => {
          console.log('failed to get png url ' + tileCode)
        })
      }
    },
    requestTif (year, day, tileNum) {
      var tileCode = this.dateCode + '_' + tileNum
      if(this.$store.state.tiles.tifs[tileCode] === undefined){
        this.$store.commit('tiles/setTif', {tileCode: tileCode, tif: null})
        this.$http.get(xHTTPx + '/get_download_url/' + year + '/' + day + '/' + tileNum + '/tif').then((response) => {
          var obj = {tileCode: tileCode, tif: xHTTPx + response.body}
          this.$store.commit('tiles/setTif', obj)
        }, (response) => {
          console.log('failed to get tif url ' + tileCode)
        })
      }
    },
    distanceInPixel (p1, p2) {
      var pixelPerUnit = this.tileSize / 15
      var distX = Math.round((Math.abs(p2[0] - p1[0])) * pixelPerUnit)
      var distY = Math.round((Math.abs(p2[1] - p1[1])) * pixelPerUnit)
      return [distX, distY]
    },
    clickTile (tile) {
      if(!this.token){
        var title = 'Login Required'
        var message = 'You need to login to download the tile!'
        var confirmButton = 'Login'
        var context = {callback: this.loginConfirmed, args: []}
        this.openConfirmModal(title, message, confirmButton, context)
      }
    },
    loginConfirmed () {
      this.$router.push('/login')
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
    downloadAll () {
      var urls = []
      for(var i=0;i<this.images.length;i++){
        for(var j=0;j<this.images[i].length;j++){
          var image = this.images[i][j]
          urls.push(image.png)
          urls.push(image.tif)
        }
      }
      this.downloadOne(urls, 0)
    },
    downloadOne (urls, index) {
      var vm = this
      setTimeout(function(){
        var url = urls[index]
        vm.downloadUrl(url)
        index++
        if(index < urls.length){
          setTimeout(function(){
            vm.downloadOne(urls, index)
          }, 500)
        }
      }, 500)
    },
    downloadUrl (url) {
      var dl = document.createElement('a')
      dl.setAttribute('href', url)
      dl.setAttribute('visibility', 'hidden')
      dl.setAttribute('display', 'none')
      dl.setAttribute('download', '')
      document.body.appendChild(dl)
      dl.click()
    },
    deleteWindow () {
      this.$emit('tile-window-deleted', this.wid)
    }
  },
  mounted () {
    this.date = this.mainDate
    this.tileSize = this.mainTileSize
    this.ready = true
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.images-box {
  margin-left: 15px;
  margin-right: 15px;
  margin-bottom: 20px;
  padding-left: 40px;
  padding-right: 50px;
  padding-bottom: 50px;
  overflow: auto;

  .image-options {
    text-align: center;

    .image-input {

      .image-input-label {
        line-height: 38px;
      }

      .image-input-input {
        width: 80px;
        display: inline-block;
        margin-top: 2px;
      }
    }

    .delete-button {
      float: right;
    }
  }

  .image-container {
    position: relative;
    margin: auto;

    .image-row {
      padding: 0px;
      white-space: nowrap;

      .image-cell {
        display: inline-flex;
      }

      .tile-border {
        border: 1px solid gray;
      }
    }

    .selection-on-image {
      position: absolute;
      border: 2px solid red;
      pointer-events: none;
    }

    .color-band-container {
      position: absolute;
      top: 0px;

      .color-band {
        width: 20px;
        background-color: red;
        border-radius: 3px;

        background: rgb(0,128,0); /* For browsers that do not support gradients */
        background: -webkit-linear-gradient(rgb(75,0,130), rgb(0,0,139), rgb(30,144,255), rgb(0,128,0), rgb(255,255,0), rgb(255,69,0), rgb(255,0,0)); 
        background: -o-linear-gradient(rgb(75,0,130), rgb(0,0,139), rgb(30,144,255), rgb(0,128,0), rgb(255,255,0), rgb(255,69,0), rgb(255,0,0)); /* For Opera 11.1 to 12.0 */
        background: -moz-linear-gradient(rgb(75,0,130), rgb(0,0,139), rgb(30,144,255), rgb(0,128,0), rgb(255,255,0), rgb(255,69,0), rgb(255,0,0)); /* For Firefox 3.6 to 15 */
        background: linear-gradient(rgb(75,0,130), rgb(0,0,139), rgb(30,144,255), rgb(0,128,0), rgb(255,255,0), rgb(255,69,0), rgb(255,0,0)); /* Standard syntax */
      }

      .color-annotation {
        font-size: 14px;
        position: absolute;
        left: 25px;        
      }
    }

    .y-annotation {
      position: absolute;
      left: -4px;
      height: 0px;
      width: 5px;
      border: 1px solid gray;

      .y-label {
        position: absolute;
        left: -30px;
        top: -10px;
        font-size: 14px;
      }
    }

    .x-annotation {
      position: absolute;
      height: 5px;
      width: 0px;
      border: 1px solid gray;

      .x-label {
        position: absolute;
        left: -10px;
        top: 10px;
        font-size: 14px;
      }
    } 
  }
}

</style>
