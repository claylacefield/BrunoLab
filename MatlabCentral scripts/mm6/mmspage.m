function mmspage(arg)
%MMSPAGE Set Figure Paper Position When Printed using a GUI. (MM)
% MMSPAGE allows the user to set the current figure position
% on the printed page using a gui.
% MMSPAGE(Hf) positions the figure having handle Hf.
%
% Editable text boxes: Left Bottom Width Height
% sets the respective figure position on the page.
%
% Pushbuttons:
%  Rotate 90   toggles paper orientation between portrait and landscape.
%  Set Default makes current position and orientation default for future.
%  Get Factory changes the figure position and orientation to factory values.
%  L/R Center  centers the figure position Left to Right.
%  U/D Center  centers the figure position Up to Down.
%  WYSIWYG     makes the Width and Height identical to the Figure Window.
%  Get Default sets the figure position to the Default values.
%  Revert      restores the figure position and orientation
%              to that when MMSPAGE was called.
%  Done        closes the MMSPAGE GUI.
%
% Usage: create figure, call MMSPAGE, then print.

% Calls: mmgcf

% D.C. Hanselman, University of Maine, Orono, ME, 04469
% 4/25/95, revised 7/21/96, v5: 1/15/97, 2/13/97
% Mastering MATLAB 5, Prentice Hall, ISBN 0-13-858366-8
% Mastering MATLAB 6, Prentice Hall, ISBN 0-13-019468-9

global Hf_2p Hf_gui Ha_gui Hp_gui Hu_l Hu_b Hu_w Hu_h PP PO PU


figrgb=[.8 .8 .8];   % background figure color
boxrgb=[.5 .5 .5];
axesrgb=0.95*[1 1 1];% axes background color
xyrgb=[0 0 0];      % grid and label color
bdr=[.25 .5];       % minimum border around figure

if nargin==0
   arg=mmgcf(1);
end
if length(arg)==1 & arg>0  % must be a Figure handle
   Hf_2p=arg;
   pu=get(Hf_2p,'PaperUnits');
   if ~strcmp(pu,'inches')&~strcmp(pu,'centimeters')
      set(Hf_2p,'PaperUnits','inches')
      pu='inches';
   end
   if strcmp(pu,'inches'),
      xyunits='inches'; TINC=1;
   else  % centimeters
      xyunits='cm';TINC=2;
   end
   ps=get(Hf_2p,'PaperSize');
   pp=get(Hf_2p,'PaperPosition');
   pp=[max(pp(1:2),.028*ps) min(pp(3:4),.96*ps)]; % limit size
   po=get(Hf_2p,'PaperOrientation');
   if strcmp(po,'landscape')  % make sure paper position is centered
      pp(2)=(ps(2)-pp(4))/2; % on landscape orientation
      pp(1)=(ps(1)-pp(3))/2;
   end
   
   set(Hf_2p,'PaperPosition',pp)
   
   if isempty(PP)
      PP=pp; % store paper position
      PO=po; % store paper orientation
      PU=TINC; % store paper unit type
   end
   
   psn=.7*ps./max(ps);
   fp=[0 .95-psn(2) psn];
   Hf_gui=figure(...  % create GUI figure
      'Color',figrgb,...
      'Units','normalized',...
      'Position',fp,...
      'MenuBar',menubar,...
      'BackingStore','off',...
      'Colormap',[],...
      'InvertHardcopy','off',...
      'PaperPositionMode','auto',...
      'IntegerHandle','off',...
      'NumberTitle','off',...
      'Name','MM: Set Printed Figure Position',...
      'Resize','off',...
      'Visible','off');
   
   Ha_gui=axes(...   % create axes showing paper size
      'Box','on',...
      'Color',axesrgb,...
      'Drawmode','fast',...
      'NextPlot','add',...
      'View',[0 90],...
      'Units','normalized',...
      'Position',[0 .18 .74 .74],...
      'XColor',xyrgb,...
      'YColor',xyrgb,...
      'Xgrid','on',...
      'Ygrid','on',...
      'Xlim',[0 ps(1)],...
      'Ylim',[0 ps(2)],...
      'XLimMode','manual',...
      'YLimMode','manual',...		
      'Xtick',0:TINC:ps(1),...
      'Ytick',0:TINC:ps(2));	
   
   set(Ha_gui,'DataAspectRatio',[1 1 1])
   
   Ht_x=text(0,0,['Paper Width, ' xyunits],...
      'FontSize',12,'Color',xyrgb);
   Ht_y=text(0,0,['Paper Height, ' xyunits],...
      'FontSize',12,'Color',xyrgb);
   Ht_t=text(0,0,['Paper Type: ' get(Hf_2p,'Papertype')],...
      'FontSize',12,'Color',xyrgb);	
   set(Ha_gui,'XLabel',Ht_x,'Ylabel',Ht_y,'Title',Ht_t)
   
   xpg=[pp(1) pp(1)+pp(3) pp(1)+pp(3) pp(1)];
   ypg=[pp(2) pp(2) pp(2)+pp(4) pp(2)+pp(4)];
   Hp_gui=fill(xpg,ypg,boxrgb); % draw box showing figure placement
   
   
   Hu_l=uicontrol(...  % left edit box
      'Style','edit',...
      'Units','normalized',...
      'Position',[.01 .05 .15 .05],...
      'String',sprintf('%.2f',pp(1)),...
      'Callback','mmspage(-1)');
   
   h=get(Hu_l,'extent');h=1.5*h(4);  % required text height
   set(Hu_l,'position',[.01 .05 .15 h])
   uicontrol(...
      'Style','text',...
      'BackGroundColor',figrgb,...
      'Units','normalized',...
      'Position',[.01 0 .15 .04],...
      'HorizontalAlignment','left',...
      'String','Left');
   
   Hu_b=uicontrol(...  % bottom edit box
      'Style','edit',...
      'Units','normalized',...
      'Position',[.18 .05 .15 h],...
      'String',sprintf('%.2f',pp(2)),...
      'Callback','mmspage(-1)');
   uicontrol(...
      'Style','text',...
      'BackGroundColor',figrgb,...
      'Units','normalized',...
      'Position',[.18 0 .15 .04],...
      'HorizontalAlignment','left',...
      'String','Bottom');
   
   Hu_w=uicontrol(...  % width edit box
      'Style','edit',...
      'Units','normalized',...
      'Position',[.35 .05 .15 h],...
      'String',sprintf('%.2f',pp(3)),...
      'Callback','mmspage(-1)');
   uicontrol(...
      'Style','text',...
      'BackGroundColor',figrgb,...
      'Units','normalized',...
      'Position',[.35 0 .15 .04],...
      'HorizontalAlignment','left',...
      'String','Width');
   
   Hu_h=uicontrol(...  % height edit box
      'Style','edit',...
      'Units','normalized',...
      'Position',[.52 .05 .15 h],...
      'String',sprintf('%.2f',pp(4)),...
      'Callback','mmspage(-1)');
   uicontrol(...
      'Style','text',...
      'BackGroundColor',figrgb,...
      'Units','normalized',...
      'Position',[.52 0 .15 .04],...
      'HorizontalAlignment','left',...
      'String','Height');
   
   b=0.05+(h+.01)*(0:8);
   uicontrol(...  % DONE
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(1) .18 h],...
      'String','Done',...
      'Callback','mmspage(-99)' );
   
   uicontrol(...  % REVERT -2
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(2) .18 h],...
      'String','Revert',...
      'Callback','mmspage(-2)');
   
   uicontrol(...  % Factory -8
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(3) .18 h],...
      'String','Get Factory',...
      'Callback','mmspage(-8)');
   
   uicontrol(...  % Get DEFAULT -3
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(4) .18 h],...
      'String','Get Default',...
      'Callback','mmspage(-3)');
   
   uicontrol(...  % Set Default -7
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(5) .18 h],...
      'String','Set Default',...
      'Callback','mmspage(-7)');
   
   uicontrol(...  % U/D Center -5
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(6) .18 h],...
      'String','U/D Center',...
      'Callback','mmspage(-5)');
   
   uicontrol(...  % L/R Center -6
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(7) .18 h],...
      'String','L/R Center',...
      'Callback','mmspage(-6)');
   
   uicontrol(...  % WYSIWYG -4
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(8) .18 h],...
      'String','WYSIWYG',...
      'Callback','mmspage(-4)');
   
   uicontrol(...  % Rotate -9
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',[.81 b(9) .18 h],...
      'String','Rotate 90',...
      'Callback','mmspage(-9)');
   
   set(Hf_gui,'Visible','on','HandleVisibility','callback')
   
elseif length(arg)==4  % update gui display
   
   pp=arg;
   set(Hu_l,'String',sprintf('%.2f',pp(1)))
   set(Hu_b,'String',sprintf('%.2f',pp(2)))
   set(Hu_w,'String',sprintf('%.2f',pp(3)))
   set(Hu_h,'String',sprintf('%.2f',pp(4)))
   
   set(Hf_2p,'PaperPosition',pp)
   
   xpg=[pp(1) pp(1)+pp(3) pp(1)+pp(3) pp(1)];
   ypg=[pp(2) pp(2) pp(2)+pp(4) pp(2)+pp(4)];
   
   set(Hp_gui,'Xdata',xpg,'Ydata',ypg)  % adjust figure patch
   
elseif arg==-1  % User-edited data
   
   mps=get(Hf_2p,'PaperSize');
   pp=zeros(1,4);
   % prioritize left over width and bottom over height
   pp(1)=max(abs(eval(get(Hu_l,'String'))),bdr(PU));             % left
   pp(3)=min(abs(eval(get(Hu_w,'String'))),mps(1)-bdr(PU)-pp(1));% width
   
   pp(2)=max(abs(eval(get(Hu_b,'String'))),bdr(PU));             % bottom
   pp(4)=min(abs(eval(get(Hu_h,'String'))),mps(2)-bdr(PU)-pp(2));% height
   mmspage(pp)
   
elseif arg==-2  % Revert
   
   if strcmp(get(Hf_2p,'PaperOrientation'),PO)
      mmspage(PP)
   else
      set(Hf_2p,'PaperOrientation',PO,...
         'PaperPosition',PP)
      close(Hf_gui)
      mmspage(Hf_2p)
   end
   
elseif arg==-3  % Get Default
   
   set(Hf_2p,'PaperPosition','default')
   pp=get(Hf_2p,'PaperPosition');
   mmspage(pp)
   
elseif arg==-4  % WYSIWYG
   
   f_units=get(Hf_2p,'Units');
   set(Hf_2p,'Units',get(Hf_2p,'PaperUnits'))
   fp=get(Hf_2p,'Position');
   set(Hf_2p,'Units',f_units)
   ps=get(Hf_2p,'PaperSize');
   pp=zeros(1,4);
   pp(3:4)=min(fp(3:4),0.96*ps);  % limit width and height to paper size
   pp(1)=(ps(1)-pp(3))/2;         % left
   pp(2)=(ps(2)-pp(4))/2;         % bottom
   mmspage(pp)
   
elseif arg==-5  % U/D Center
   
   pp=get(Hf_2p,'PaperPosition');
   ps=get(Hf_2p,'PaperSize');
   po=get(Hf_2p,'PaperOrientation');
   if strcmp(po,'landscape')
      ps=[max(ps) min(ps)]; % fix size if landscape
   end
   pp(2)=(ps(2)-pp(4))/2;         % bottom
   mmspage(pp)
   
elseif arg==-6  % L/R Center
   
   pp=get(Hf_2p,'PaperPosition');
   ps=get(Hf_2p,'PaperSize');
   po=get(Hf_2p,'PaperOrientation');
   if strcmp(po,'landscape');
      ps=[max(ps) min(ps)]; % fix size if landscape
   end
   pp(1)=(ps(1)-pp(3))/2;         % left
   mmspage(pp)
   
elseif arg==-7  % Set Default
   
   pp=get(Hf_2p,'PaperPosition');
   set(0,'DefaultFigurePaperPosition',pp)
   po=get(Hf_2p,'PaperOrientation');
   set(0,'DefaultFigurePaperOrientation',po)
   
elseif arg==-8  % Factory
   
   set(Hf_2p,'PaperOrientation','factory','PaperPosition','factory')
   close(Hf_gui)
   mmspage(Hf_2p)
   
elseif arg==-9  % Rotate 90
   
   po=get(Hf_2p,'PaperOrientation');
   if strcmp(po,'portrait')
      set(Hf_2p,'PaperOrientation','landscape')
   else
      set(Hf_2p,'PaperOrientation','portrait')
   end
   set(Hf_2p,'PaperPosition','factory')
   close(Hf_gui)
   mmspage(Hf_2p)
   
elseif arg==-99  % Done
   
   close(Hf_gui)
   Hf_2p=[]; Hf_gui=[]; Ha_gui=[]; Hp_gui=[];
   Hu_l=[]; Hu_b=[]; Hu_w=[]; Hu_h=[]; PP=[]; PO=[]; PU=[];
   
end
