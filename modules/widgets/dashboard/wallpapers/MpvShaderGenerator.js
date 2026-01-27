.pragma library

function generate(paletteColors) {
    // Safety check
    if (!paletteColors || paletteColors.length === 0) {
        // Return a passthrough shader if no palette
        return `//!HOOK MAIN
//!BIND HOOKED
//!DESC Ambxst Passthrough
void main() {
    HOOKED_col = HOOKED_tex(HOOKED_pos);
}`;
    }

    let unrolledLogic = "";
    
    // Unroll the loop to ensure compatibility with all GLES drivers
    // (Dynamic indexing of arrays is often broken or slow in shaders)
    for (let i = 0; i < paletteColors.length; i++) {
        let color = paletteColors[i];
        
        let r = (color.r !== undefined ? color.r : 0.0).toFixed(5);
        let g = (color.g !== undefined ? color.g : 0.0).toFixed(5);
        let b = (color.b !== undefined ? color.b : 0.0).toFixed(5);
        
        unrolledLogic += `
    {
        vec3 pColor = vec3(${r}, ${g}, ${b});
        vec3 diff = color - pColor;
        float distSq = dot(diff, diff); 
        float weight = exp(-distributionSharpness * distSq);
        accumulatedColor += pColor * weight;
        totalWeight += weight;
    }
`;
    }

    return `//!HOOK MAIN
//!BIND HOOKED
//!DESC Ambxst Palette Tint

vec4 hook() {
    vec4 tex = HOOKED_tex(HOOKED_pos);
    vec3 color = tex.rgb;

    vec3 accumulatedColor = vec3(0.0);
    float totalWeight = 0.0;
    
    // "Sharpness" factor matches QML shader.
    float distributionSharpness = 20.0; 

    // Unrolled palette comparison
    ${unrolledLogic}

    // Normalize
    vec3 finalColor = accumulatedColor / (totalWeight + 0.00001);

    // Fallback: If no color matches well (weight near zero), keep original
    // This prevents solid background colors if something goes wrong
    if (totalWeight < 0.0001) {
        finalColor = color;
    }

    return vec4(finalColor, tex.a);
}
`;
}
