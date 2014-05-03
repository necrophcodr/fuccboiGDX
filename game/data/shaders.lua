shaders = {}
shaders['combine'] = love.graphics.newShader[[
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 texcolor = Texel(texture, texcoord);
        return vec4(vcolor.rgb + texcolor.rgb - 0.5, texcolor.a);
    }
]]

shaders['posterize'] = love.graphics.newShader[[
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        float gamma = 1.0;
        float n_colors = 2.0;
        vec4 texcolor = Texel(texture, texcoord);
        vec3 c = texcolor.rgb;
        c = pow(c, vec3(gamma, gamma, gamma));
        c = c * n_colors;
        c = floor(c);
        c = c / n_colors;
        c = pow(c, vec3(1.0/gamma));
        return vec4(c, texcolor.a);
    }
]]

shaders['pixelize'] = love.graphics.newShader[[
    extern float w;
    extern float h;
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 tc = vec4(0.0, 0.0, 0.0, 0.0);
        float dx = 0.5*(1./w);
        float dy = 0.5*(1./h);
        vec2 coord = vec2(dx*floor(texcoord.x/dx), dy*floor(texcoord.y/dy));
        tc = Texel(texture, coord);
        return tc;
    }
]]

shaders['pixelize1'] = love.graphics.newShader[[
    extern float w;
    extern float h;
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 tc = vec4(0.0, 0.0, 0.0, 0.0);
        float dx = 0.25*(1./w);
        float dy = 0.25*(1./h);
        vec2 coord = vec2(dx*floor(texcoord.x/dx), dy*floor(texcoord.y/dy));
        tc = Texel(texture, coord);
        return tc;
    }
]]

shaders['alpha_test'] = love.graphics.newShader[[
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 texcolor = Texel(texture, texcoord);
        return texcolor.a > 0.3 ? vec4(vcolor.r, vcolor.g, vcolor.b, texcolor.a) : vec4(1, 1, 1, 0);
    }

]]

shaders['water_alpha_test'] = [[
    extern vec3 outc;
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 texcolor = Texel(texture, texcoord);
        return texcolor.a > 0.7 ? vec4((outc[0]/255.0)*texcolor.r, (outc[1]/255.0)*texcolor.g, (outc[2]/255.0)*texcolor.b, texcolor.a) : vec4(1, 1, 1, 0);
    }
]]

shaders['lava_alpha_test'] = [[
    extern vec3 outc;
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 texcolor = Texel(texture, texcoord);
        return texcolor.a > 0.7 ? vec4((outc[0]/255.0)*texcolor.r, (outc[1]/255.0)*texcolor.g, (outc[2]/255.0)*texcolor.b, texcolor.a) : vec4(1, 1, 1, 0);
    }
]]

shaders['repulsion_alpha_test'] = [[
    extern vec3 outc;
    vec4 effect(vec4 vcolor, Image texture, vec2 texcoord, vec2 pixcoord) {
        vec4 texcolor = Texel(texture, texcoord);
        return texcolor.a > 0.95 ? vec4((outc[0]/255.0)*texcolor.r, (outc[1]/255.0)*texcolor.g, (outc[2]/255.0)*texcolor.b, texcolor.a) : vec4(1, 1, 1, 0);
    }
]]
