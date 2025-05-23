function [parCE] = parContrastEnhance(parmat, sphereRad)

sizeT = size(parmat, 4);
fprintf('MCP Data Contrast Enhancement Progress:\n');
fprintf(['\n' repmat('.', 1, sizeT) '\n\n']);

parfor t = 1 : sizeT
    fprintf('\b|\n');

    frame = parmat(:,:,:,t);
    th = imtophat(frame, strel('sphere', sphereRad));
    fth = frame+th;
    bg = imbothat(fth, strel('sphere', sphereRad));
    ce = fth-bg;
    parCE(:,:,:,t) = ce;
end