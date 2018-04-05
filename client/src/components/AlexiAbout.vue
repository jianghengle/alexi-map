<template>
  <div class="">
    <div class="container">
      <div class="content text-content">
        <h4 class="p-header">Overview</h4>
        <p>Evapotranspiration (ET) is a very difficult climate and crop parameter to measure directly and yet is needed for assessing water budgets, water productivity, plant stress, and drought.  Remote sensing of crop ET, however, has become reliable and accurate over the last decade with the implementation of several different energy and water balance models.  The Atmosphere-Land Exchange Inverse (ALEXI) two-source energy balance (TSEB) model, developed by USDA ARS, is used to calculate the Global Daily Evapo-Transpiration (GloDET) dataset.  ALEXI produces a high resolution (375-m) ET product, over 60% better resolution than the current MODIS capability (1000-m).  A scientific description of the ALEXI model, including an overview of the TSEB equation set, is available here. The ALEXI model is unique among existing thermal ET models in that:</p>
        <ol>
          <li type="a">ALEXI is based on a two-source land-surface representation (the TSEB), which treats the land surface as a composite of soil and vegetation elements with different temperatures, fluxes, and atmospheric coupling. This results in a single model formulation that can be applied to a wide range of canopy and moisture stress conditions, including partially vegetated surfaces (<em>Anderson et al., 2007</em>).</li>
          <li type="a">ALEXI inherently uses the high-temporal resolution (hourly) information provided by geostationary satellites to reduce sensitivity to sensor bias and to provide time-continuous flux predictions over continental scales (<em>Anderson et al., 2007</em>).</li>
        </ol>

        <h4 class="p-header">Model Inputs</h4>
        <p>The ALEXI model does not require precipitation as an input, nor does it need information about subsurface soil texture.  Instantaneous ET rates are linked to observables like land-surface temperature and vegetation cover fraction (<em>Anderson et al., 2007</em>).  Inputs includes: 1) mid-morning change in land surface temperature, 2) leaf area index and fraction of green vegetation cover, 3) land surface albedo, 4) incoming solar radiation, 4) meteorological surface fields (air temperature; wind speed; surface pressure; incoming LW), 5) morning profile of potential temperature, 6) land cover and vegetation type, and 7) cloud mask.</p>

        <p>Morning Land Surface Temperature (LST) rise in the eastern hemisphere is a needed to run ALEXI in the MENA region.  The NASA Geostationary Operational Environmental Satellite system (GOES) provides coverage of the western hemispheres and continuous LST data.  The polar-orbiting MODIS & VIIRS sensor provides global coverage and twice daily LST measurements. A technique has been developed and evaluated using GOES data to train a regression model to use day-minus-night LST differences from MODIS/VIIRS to predict the morning LST rise in the MENA region (Figure 1) (root mean squared error ~ 5 to 8%).</p>
        <p style="text-align: center"><img src="static/About_Figure1.png" width="700"></p>

        <h4 class="p-header">Algorithms</h4>
        <p><em>[Source: Anderson et al., 2007]</em><br/>
        The land-surface representation in ALEXI model is based on the series version of the two-source energy balance model of Norman et al. [1995; see also Kustas and Norman, 1999, 2000]. The TSEB partitions the composite surface radiometric temperature, TRAD, into characteristic soil and canopy temperatures, TS and TC, based on the local vegetation cover fraction apparent at the thermal sensor view angle, <img src="static/equation1.gif" border="0"/>:</p>
        <p style="text-align: center"><img src="static/equation2.gif"></p>
        <p>(Figure 2), where equation 2 is a linear approximation to an aggregation of surface radiance values. With this information, the TSEB evaluates the soil (subscript ‘s’) and the canopy (‘c’) energy budgets separately, computing system and component fluxes of net radiation (RN = RN<sub>C</sub> + RN<sub>S</sub>), sensible and latent heat (H = H<sub>C</sub> + H<sub>S</sub> and λE = λE<sub>C</sub> + λE<sub>S</sub>), and soil heat conduction (G). Because angular effects are incorporated into the decomposition of TRAD, the TSEB can accommodate thermal data acquired at off-nadir viewing angles and can therefore be applied to geostationary satellite images.</p>
        <p style="text-align: center"><img src="static/About_Figure2.png" width="700"></p>

        <h4 class="p-header">Model Output</h4>
        <p>The ALEXI model produces high-resolution (375-m) ET Products.  Processing nodes are 15 x 15 degree boxes, shown as gray grid cells in the GloDET Data Explorer.  Shaded gray boxes denote active processing nodes.</p>
        <p>The disadvantage to remote sensing modeling is that the output record often suffers large spatial and temporal gaps due to cloud cover and infrequent image availability as governed by the satellite overpass schedule (<em>Anderson et al., 2007</em>).  Data post-processing and gap filling will be used to resolve this issue for the GloDET dataset.  </p>

        <h4 class="p-header">Citation Instructions</h4>
        <p>When using GloDET datasets in your work, please ensure that you always cite the data as:</p>
        <ul style="list-style-type: none;"><li>Robert B. Daugherty Water for Food Global Institute. (2018). GloDET: Global daily evapo-transpiration. University of Nebraska. Lincoln, NE, USA. &lt;glodet.nebraska.edu&gt;.</li></ul>
        <p>In addition, please also acknowledge appropriately the original USDA ARS ALEXI model and research by citing associated key publications, such as:</p>
        <ul style="list-style-type: none;">
          <li>Anderson, M. C., J. M. Norman, J. R. Mecikalski, J. A. Otkin, and W. P. Kustas. (2007a). A climatological study of evapotranspiration and moisture stress across the continental United States based on thermal remote sensing: 1. Model formulation. J. Geophys. Res. Vol 112, D10117, doi:10.1029/2006JD007506.</li>
          <li>Anderson, M. C., J. M. Norman, J. R. Mecikalski, J. P. Otkin, and W. P. Kustas. (2007b). A climatological study of evapotranspiration and moisture stress across the continental U.S. based on thermal remote sensing: II. Surface moisture climatology, J. Geophys. Res., Vol 112, doi:10.1029/2006JD007507.</li>
        </ul>

        <br/>
        <h4 class="p-header">Development Team</h4>
        <br/>
        <div class="columns">
          <div class="column">
            <div class="columns">
              <div class="column" style="text-align: right;">
                <img src="static/Martha.png" width="250">
              </div>
              <div class="column" style="margin: auto;">
                <strong>Martha Anderson, Ph.D.</strong><br/>
                Martha Anderson is the author of the ALEXI two-source energy balance model.  Martha is a Research Physical Scientist at the USDA-ARS Hydrology and Remote Sensing Laboratory in Beltsville, Maryland.
              </div>
            </div>
          </div>
          <div class="column">
            <div class="columns">
              <div class="column" style="text-align: right;">
                <img src="static/Chris_Hain.png" width="250">
              </div>
              <div class="column" style="margin: auto;">
                <strong>Christopher Hain, Ph.D.</strong><br/>
                Research Scientist, Short-term Prediction Research and Transition Center, NASA
              </div>
            </div>
          </div>
        </div>
        <div class="columns">
          <div class="column">
            <div class="columns">
              <div class="column" style="text-align: right;">
                <img src="static/01_Mitchell_Schull_WEB.jpg" width="250">
              </div>
              <div class="column" style="margin: auto;">
                <strong>Mitchell Schull, Ph.D.</strong><br/>
                Post-Doctoral Associate, Earth System Science Interdisciplinary Center (ESSIC), University of Maryland College Park
              </div>
            </div>
          </div>
          <div class="column">
            <div class="columns">
              <div class="column" style="text-align: right;">
                <img src="static/01_Christopher_Neale.jpg" width="250">
              </div>
              <div class="column" style="margin: auto;">
                <strong>Christopher Neale, Ph.D.</strong><br/>
                Director of Research, Daugherty Water for Food Global Institute, University of Nebraska
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-about',
}
</script>

<style lang="scss" scoped>

.text-content {
  margin-bottom: 30px;
}

.p-header{
  font-weight: bold;
  margin-bottom: 0.5em;
  color: #05485A;
}

</style>
