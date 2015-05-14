#version 120
#extension GL_ARB_texture_rectangle: enable

/************************************************************
 MASK MASK shader
 *  Takes in a color (ko_color), a texture (tex0),
    and a mode (mode, duh) and either passes through
    the texture as-is (mode 1) or renders pixels based
    on the KO color: clear if KO color, black otherwise
************************************************************/

uniform vec4 ko_color;
uniform sampler2DRect tex0;
uniform int mode;

void main(){
    // "render"
    if ( mode == 0 ){
        vec4 texColor = texture2DRect(tex0, gl_TexCoord[0].st);
        if ( texColor == ko_color ) texColor = vec4(0,0,0,0);
        else texColor = vec4(0,0,0,1);
        
        gl_FragColor = texColor;
        
    // "edit"
    } else {//if ( mode == 1 ){
        vec4 texColor = texture2DRect(tex0, gl_TexCoord[0].st);
        gl_FragColor = texColor;
    }
}