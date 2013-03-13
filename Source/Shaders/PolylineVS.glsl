attribute vec3 position3DHigh;
attribute vec3 position3DLow;
attribute vec3 otherPosition3DHigh;
attribute vec3 otherPosition3DLow;
attribute vec4 color;
attribute vec4 misc;

#ifndef RENDER_FOR_PICK
varying vec4 v_color;
varying vec4 v_outlineColor;
varying vec2 v_textureCoordinates;
#else
varying vec4 v_pickColor;
#endif

uniform float u_morphTime;

const float radius = 100000.0;
const float invScrRatio = 751.0 / 670.0;

void main() 
{
    vec2 offset = misc.xy;
    vec2 texCoords = misc.zw;
    
    vec4 p = vec4(czm_translateRelativeToEye(position3DHigh, position3DLow), 1.0);
    p = czm_modelViewProjectionRelativeToEye * p;
    
    vec4 op = vec4(czm_translateRelativeToEye(otherPosition3DHigh, otherPosition3DLow), 1.0);
    op = czm_modelViewProjectionRelativeToEye * op;

    //  line direction in screen space (perspective division required)
    vec2 lineDirProj = radius * normalize(p.xy / p.ww - op.xy / op.ww);

    // small trick to avoid inversed line condition when points are not on the same side of Z plane
    if(sign(op.w) != sign(p.w))
        lineDirProj = -lineDirProj;

    // offset position in screen space along line direction and orthogonal direction
    p.xy += lineDirProj.xy                      * offset.xx * vec2(1.0, invScrRatio);
    p.xy += lineDirProj.yx * vec2(1.0, -1.0)    * offset.yy * vec2(1.0, invScrRatio);

    
#ifndef RENDER_FOR_PICK
    vec3 alphas = czm_decodeColor(color.b);
    v_color = vec4(czm_decodeColor(color.r), alphas.r);
    v_outlineColor = vec4(czm_decodeColor(color.g), alphas.g);
    v_textureCoordinates = texCoords;
#else
    v_pickColor = color;
#endif

    gl_Position = p;
}
