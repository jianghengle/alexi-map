<template>
  <div>
    <div class="box images-box">
      <div class="columns image-options">
        <div class="column">
          <span class="image-input">
            <label class="image-input-label">Image Size</label>
            <input class="input image-input-input" type="number" step="10" v-model.number="imageSize">
          </span>
        </div>
        <div class="column">
          <a class="button" :disabled="day==263" @click="changeDay(day-1)">
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
          <a class="button" :disabled="day==265" @click="changeDay(day+1)">
            <span class="icon is-small">
              <icon name="chevron-right"></icon>
            </span>
          </a>
        </div>
        <div class="column">
          <a class="button is-info">
            Download Images
          </a>
          <a class="button delete delete-button" @click="deleteBox" v-if="idx != 0"></a>
        </div>
      </div>
      <div>
        <div class="image-container" 
          :style="{'height': height + 'px', 'width': width + 'px'}">
          <div v-for="(row, i) in images" :key="'row-' + i" class="image-row">
            <a v-for="(cell, j) in row" :key="cell.id"
              :href="cell.tif"
              :id="cell.id">
              <img :src="cell.png"
                :height="imageSize"
                :width="imageSize"
                :class="{'tile-border': showGrids}">
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
            <div class="color-annotation" v-for="a in colorAnnotations" :style="{'top': a.top + 'px'}">
              {{a.value}}
            </div>
          </div>
          <div class="y-annotation" v-if="showGrids" v-for="a in yAnnotations" :style="{'top': a.top + 'px'}">
            <div class="y-label">
              <span v-if="a.label == '0'">&nbsp;</span>{{a.label}}
            </div>
          </div>
          <div class="x-annotation" v-if="showGrids" v-for="a in xAnnotations" :style="{'left': a.left + 'px'}">
            <div class="x-label">
              <span v-if="a.label == '0'">&nbsp;</span>{{a.label}}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import DateForm from 'dateformat'
import Datepicker from 'vuejs-datepicker'


export default {
  name: 'image-box',
  components: {
    Datepicker
  },
  props: ['selectionTiles', 'idx', 'day', 'showGrids', 'showSelection', 'maxDateWindow'],
  data () {
    return {
      imageSize: 200
    }
  },
  computed: {
    date () {
      var date = new Date('2017-01-01T00:00:00')
      date.setDate(date.getDate() + parseInt(this.day))
      return date
    },
    height () {
      return this.imageSize * this.selectionTiles.length
    },
    width () {
      return this.imageSize * this.selectionTiles[0].length
    },
    images () {
      var images = []
      for(var i=0;i<this.selectionTiles.length;i++){
        var row = this.selectionTiles[i]
        var imageRow = []
        for(var j=0;j<row.length;j++){
          var cell = row[j]
          var image = cell.days[this.day]
          imageRow.push(image)
        }
        images.push(imageRow)
      }
      return images
    },
    selection () {
      if(!this.imageSize)
        return {top: 0, left: 0, height: 0, width: 0}
      var topLeftTile = this.selectionTiles[0][0]
      var tlp2 = [topLeftTile.bounds.north, topLeftTile.bounds.west]
      var tlp1 = [topLeftTile.overlap.north, topLeftTile.overlap.west]
      var topLeftDist = this.distanceInPixel(topLeftTile, tlp1, tlp2)

      var lastRow = this.selectionTiles[this.selectionTiles.length - 1]
      var bottomRightTile = lastRow[lastRow.length - 1]
      var brp1 = [bottomRightTile.overlap.south, bottomRightTile.overlap.east]
      var brp2 = [bottomRightTile.bounds.south, bottomRightTile.bounds.east]
      var bottomRightDist = this.distanceInPixel(bottomRightTile, brp1, brp2)

      var wholeHeight = this.selectionTiles.length * this.imageSize
      var height = wholeHeight - topLeftDist[1] - bottomRightDist[1]
      var wholeWidth = lastRow.length * this.imageSize
      var width = wholeWidth - topLeftDist[0] - bottomRightDist[0]
      return {top: topLeftDist[1], left: topLeftDist[0], height: height, width: width}
    },
    dateDisabled () {
      return {to: this.maxDateWindow[0], from: this.maxDateWindow[1]}
    },
    colorAnnotations () {
      if(!this.imageSize) return []
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
      if(!this.selectionTiles ||!this.selectionTiles.length) return []
      if(!this.imageSize) return []
      var len = this.selectionTiles.length * 3
      var start = this.selectionTiles[0][0].bounds.north
      var intervel = this.imageSize / 3
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
      if(!this.selectionTiles ||!this.selectionTiles.length) return []
      if(!this.imageSize) return []
      var len = this.selectionTiles[0].length * 3
      var start = this.selectionTiles[0][0].bounds.west
      var intervel = this.imageSize / 3
      var xAnnotations = []
      for(var i=0;i<=len;i++){
        var lng = start + i * 5
        var label = lng >= 0 ? 'E' + lng : 'W' + (-lng)
        if(lng == 0) label = '0'
        var left = intervel * i - 1
        xAnnotations.push({label: label, left: left})
      }
      return xAnnotations
    }
  },
  methods: {
    distanceInPixel (tile, p1, p2) {
      var pixelPerLat = this.imageSize / (tile.bounds.north - tile.bounds.south)
      var pixelPerLng = this.imageSize / (tile.bounds.east - tile.bounds.west)
      var distX = Math.round((Math.abs(p2[1] - p1[1])) * pixelPerLng)
      var distY = Math.round((Math.abs(p2[0] - p1[0])) * pixelPerLat)
      return [distX, distY]
    },
    dateSelected (date) {
      var day = Math.round((date - new Date('2017-01-01T00:00:00')) / 86400000)
      this.changeDay(day)
    },
    changeDay (day) {
      if(day < 263 || day > 265) return
      var boxDay = {idx: this.idx, day: day}
      this.$emit('box-day-changed', boxDay)
    },
    downloadAll () {
      var vm = this
      var elements = []
      this.days.forEach(function(d){
        for(var i=0;i<vm.rectTileMatrix.length;i++){
          var row = vm.rectTileMatrix[i]
          for(var j=0;j<row.length;j++){
            var id = 'tile-' + d + '-' + i + '-' + j
            var el = document.getElementById(id)
            elements.push(el)
          }
        }
      })
      var i = 0
      vm.downloadOne(elements, i)
    },
    downloadOne (elements, index) {
      var vm = this
      setTimeout(function(){
        let el = elements[index]
        el.click()
        index++
        if(index < elements.length){
          setTimeout(function(){
            vm.downloadOne(elements, index)
          }, 500)
        }
      }, 500)
    },
    deleteBox () {
      this.$emit('box-deleted', this.idx)
    }
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
      margin-bottom: -7px;

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
