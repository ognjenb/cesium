attribute vec3 position3DHigh;
attribute vec3 position3DLow;
attribute vec3 otherPosition3DHigh;
attribute vec3 otherPosition3DLow;
attribute vec4 color;
attribute vec4 offsetDirUV;
attribute vec2 misc;

#ifndef RENDER_FOR_PICK
varying vec4 v_color;
varying vec4 v_outlineColor;
varying vec2 v_textureCoordinates;
#else
varying vec4 v_pickColor;
#endif

uniform float u_morphTime;

const float radius = 100000.0;

void main() 
{
    vec2 offset = offsetDirUV.xy;
    vec2 texCoords = offsetDirUV.zw;
    float width = misc.x;
    float show = misc.y;
    
    vec4 position = vec4(czm_translateRelativeToEye(position3DHigh, position3DLow), 1.0);
    position = czm_modelViewProjectionRelativeToEye * position;
    
    vec4 otherPosition = vec4(czm_translateRelativeToEye(otherPosition3DHigh, otherPosition3DLow), 1.0);
    otherPosition = czm_modelViewProjectionRelativeToEye * otherPosition;

    //  line direction in screen space (perspective division required)
    vec2 lineDirProj = radius * normalize(position.xy / position.ww - otherPosition.xy / otherPosition.ww);

    // small trick to avoid inversed line condition when points are not on the same side of Z plane
    if(sign(otherPosition.w) != sign(position.w))
        lineDirProj = -lineDirProj;

    // offset position in screen space along line direction and orthogonal direction
    float invScrRatio = czm_viewport.z / czm_viewport.w;
    position.xy += lineDirProj.xy                      * offset.xx * vec2(1.0, invScrRatio);
    position.xy += lineDirProj.yx * vec2(1.0, -1.0)    * offset.yy * vec2(1.0, invScrRatio);

    
#ifndef RENDER_FOR_PICK
    vec3 alphas = czm_decodeColor(color.b);
    v_color = vec4(czm_decodeColor(color.r), alphas.r);
    v_outlineColor = vec4(czm_decodeColor(color.g), alphas.g);
    v_textureCoordinates = texCoords;
#else
    v_pickColor = color;
#endif

    gl_Position = position;
}
