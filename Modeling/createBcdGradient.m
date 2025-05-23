function AP_bcdConc = createBcdGradient(alpha,Bcd0,D,tau,x)
% synthesis rate + diffusion rate - degradation rate 
% The shape of the gradient produced from a point-source of mRNA is
% exponentially distributed and is shaped according to [Bcd(x)] = alpha *
% [Bcd(0)] * exp(-x/Lambda). alpha is a constant that reflects the gene
% dosage of Bcd Bcd(0) is the conc. at the anterior pole and reflets the
% amount of Bicoid synthesized at the time of evaluation. Lambda = the
% length scale of the gradient = 1/exp = sqrt(D*tau)
%     where D is the diffusion constant and tau is the lifetime of the
%     protein
%     
% in this function, the idea is to be able to alter the variables and
% explore what this does to the shape of the gradient. The units are
% important for things to work properly. 
%     * alpha is a unitless constant that effectively represents the gene
%     dosage of bicoid
%     * Bcd(0) is in nM. The default (140 nM) is the Gregor measurement.
%     * D is in square microns per second
%     * tau is presented in minutes, because that is the relevant timescale,
%     but we have to convert this to seconds.
%     x is the fractional length of the embryo, but we need to consider the
%     true size of the embryo to derive Lambda from the inputs of D and tau.


  Lambda = sqrt(D * (tau * 60))/500; % divide by 500um to convert to fractional length
  
  concentrations = alpha * Bcd0 * exp(-x/Lambda);

  AP_bcdConc = [x' concentrations']; % first row is AP position x, second is [Bcd] @ x

end