#version 120
#extension GL_ARB_texture_rectangle: enable

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