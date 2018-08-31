function DrawConvexHull(MCC, xdim, ydim, color)

% mcconvexhull/DrawConvexHull(MCC, xd, yd, color)
if ~isempty(MCC.xdims)
   iL = find(MCC.xdims == xdim & MCC.ydims == ydim);
   if ~isempty(iL)
      h = plot(MCC.cx{iL}, MCC.cy{iL}, '-');
      set(h, 'Color', color);
   end
end
