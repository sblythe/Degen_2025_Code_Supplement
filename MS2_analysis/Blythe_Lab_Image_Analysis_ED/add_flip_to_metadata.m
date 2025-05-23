function meta = add_flip_to_metadata(I, meta)
clf
imagesc(I{:}, [min(range(I{:})) max(range(I{:}))]); axis image
i = input('Does the AP axis need to be flipped? [y N]: ','s');
if strcmp(i,'y') || strcmp(i,'Y')
    meta.flipAP = 1;
else if strcmp(i,'n') || strcmp(i,'N') || isempty(i)
        meta.flipAP = 0;
    end
end

