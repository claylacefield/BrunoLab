function mmstext(arg)
%MMSTEXT Set Text Specifications using a GUI. (MM)
% MMSTEXT creates a GUI to set or modify the specifications
% of text in the current axes.
% MMSTEXT(Ha) considers text in the axes having handle Ha.
%
% GUI Pushbuttons:
% New	- Create a New Text Object
% Delete - Delete the Selected Text Object
% Revert - Revert to Original Text Specs (but don't apply them).
% Apply  - Apply all Selected Changes
% Done   - Quit without making further changes.

% Calls: mmgcf mmgca mmsetpos mmrgb mmdeal mmlimit mmonoff
% Calls: mmis2d mmgetset mmputptr

% D.C. Hanselman, University of Maine, Orono, ME  04469
% 6/2/99, 8/24/99
% Mastering MATLAB 6, Prentice Hall, ISBN 0-13-019468-9

if nargin==0  % use current axes
   Hfgui=findall(0,'Type','figure','Tag','MMSTEXT');
   if ~isempty(Hfgui) % GUI exists, just go to it
      figure(Hfgui)
      return
   end
   H.Fig=mmgcf(1);
   arg=mmgca(H.Fig,1);
elseif ~ischar(arg) & ishandle(arg)  % use axes provided
   if ~strcmp(get(arg,'Type'),'axes')
      error('Handle Does Not Point to an Axes.')
   end
   H.Fig=get(arg,'Parent');
end
if ishandle(arg)  % initialize GUI
   Hfgui=findall(0,'Type','figure','Tag','MMSTEXT');
   if ~isempty(Hfgui) % GUI exists, close it and start over
      close(Hfgui)
   end
   figure(H.Fig)
   H.Axes=arg;
   h=20; ht=h-4;
   s=5;
   w=[85 90 75 90 110];
   left=cumsum([0 w]+s);
   r=[0  h h h h h  h h h h];
   s=[5 10 5 5 5 5 5 10 5 5];
   bottom=cumsum(r+s);
   d=(left(end)-5)/5;
   lb=5:d:left(end)-10;
   wb=d-5;
   rgb=get(0,'DefaultUicontrolBackgroundColor');
   
   
   gpos=mmsetpos([0 0 left(end) bottom(end)],H.Fig,'pixels','center','below');
   gpos=mmfitpos(gpos-[0 30 0 0],0,'pixels');
   Hfgui=figure('units','pixels',...
      'Position',gpos,...
      'MenuBar',menubar,...
      'Resize','off',...
      'BackingStore','off',...
      'Colormap',[],...
      'InvertHardcopy','off',...
      'PaperPositionMode','auto',...
      'HandleVisibility','callback',...
      'IntegerHandle','off',...
      'NumberTitle','off',...
      'Name','MM: Set Text Specs',...
      'Color',rgb,...
      'Visible','off',...
      'CloseRequestFcn','mmstext DONE',...
      'Tag','MMSTEXT');
   
   set([H.Fig H.Axes],'Units','pixels')
   
   Ht=findall(H.Axes,'Type','text'); % get text objects for manipulation
   Ht=Ht(:);
   labs={'Xlabel' 'Ylabel' 'Title'};
   for i=1:3
      Hxyt=get(H.Axes,labs{i});
      if ~any(Hxyt==Ht) % add label if not there
         Ht=[Ht;Hxyt];
      end
      if length(get(Hxyt,'String'))==0 % fill label if not there
         set(Hxyt,'String',labs{i})
      end
   end
   set(Ht,'Units','normalized','FontUnits','points')
   Tp=mmgetset(Ht); % structure array of settable text property values
   n=1; % which text object to select
   
   uicontrol('Parent',Hfgui,'Style','PushButton',... % Delete Pushbutton
      'Units','pixels',...
      'Position',[lb(1) bottom(1) wb h],...
      'String','Delete',...
      'Callback','mmstext DELETE');
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(2) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','Visible')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(3) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','Clipping')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(4) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','Interpreter')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(5) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','FontWeight')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(6) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','FontAngle')
   uicontrol('Parent',Hfgui,'Style','Pushbutton',...
      'Units','pixels',...
      'Position',[left(1) bottom(7) w(1) h],...
      'HorizontalAlignment','right',...
      'String','FontName',...
      'Callback','mmstext UISETFONT')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(8) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','Edit')	
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(1) bottom(9) w(1) ht],...
      'HorizontalAlignment','right',...
      'String','Select')
   
   uicontrol('Parent',Hfgui,'Style','PushButton',... % New Pushbutton
      'Units','pixels',...
      'Position',[lb(2) bottom(1) wb h],...
      'String','New',...
      'Callback','mmstext NEW');
   H.Visible=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(2) bottom(2) w(2) h],...
      'String','On|Off',...
      'Value',2-mmonoff(Tp(n).Visible));
   H.Clipping=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(2) bottom(3) w(2) h],...
      'String','On|Off',...
      'Value',2-mmonoff(Tp(n).Clipping));
   H.Interpreter=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(2) bottom(4) w(2) h],...
      'String','Tex|None',...
      'Value',1+strcmp(Tp(n).Interpreter,'none'));
   H.FontWeight=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(2) bottom(5) w(2) h],...
      'String','Light|Normal|Demi|Bold',...
      'Value',local_weight(Tp(n).FontWeight));
   H.FontAngle=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(2) bottom(6) w(2) h],...
      'String','Normal|Italic|Oblique',...
      'Value',local_angle(Tp(n).FontAngle));
   H.FontName=uicontrol('Parent',Hfgui,'Style','Edit',...
      'Units','pixels',...
      'Position',[left(2) bottom(7) w(2) h],...
      'String',Tp(n).FontName);
   H.EditString=uicontrol('Parent',Hfgui,'Style','Edit',...
      'Units','pixels',...
      'Position',[left(2) bottom(8) left(end)-left(2)-5 h],...
      'String',Tp(n).String,...
      'HorizontalAlignment','left');
   H.SelectText=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(2) bottom(9) left(end)-left(2)-5 h],...
      'String',{Tp(:).String},...
      'Value',n,...
      'Callback','mmstext SELECT');
   
   uicontrol('Parent',Hfgui,'Style','PushButton',... % Revert Pushbutton
      'Units','pixels',...
      'Position',[lb(3) bottom(1) wb h],...
      'String','Revert',...
      'Callback','mmstext REVERT');		
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(3) bottom(2) w(3) ht],...
      'HorizontalAlignment','right',...
      'String','V-Align')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(3) bottom(3) w(3) ht],...
      'HorizontalAlignment','right',...
      'String','H-Align')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(3) bottom(4) w(3) ht],...
      'HorizontalAlignment','right',...
      'String','Rotation')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(3) bottom(5) w(3) ht],...
      'HorizontalAlignment','right',...
      'String','Position')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(3) bottom(6) w(3) ht],...
      'HorizontalAlignment','right',...
      'String','Color')
   uicontrol('Parent',Hfgui,'Style','text',...
      'BackgroundColor',rgb,...
      'Units','pixels',...
      'Position',[left(3) bottom(7) w(3) ht],...
      'HorizontalAlignment','right',...
      'String','Size')
   
   
   uicontrol('Parent',Hfgui,'Style','Pushbutton',... % Apply Pushbutton
      'Units','pixels',...
      'Position',[lb(4) bottom(1) wb h],...
      'String','Apply',...
      'Callback','mmstext APPLY');
   H.VerticalAlignment=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(4) bottom(2) w(4) h],...
      'String','Top|Cap|Middle|Baseline|Bottom',...
      'Value',local_valign(Tp(n).VerticalAlignment));
   H.HorizontalAlignment=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(4) bottom(3) w(4) h],...
      'String','Left|Center|Right',...
      'Value',local_halign(Tp(n).HorizontalAlignment));
   H.Rotation=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(4) bottom(4) w(4) h],...
      'String','0|90|180|-90|Other->',...
      'Value',local_rotate(Tp(n).Rotation));
   H.DragText=uicontrol('Parent',Hfgui,'Style','Pushbutton',...
      'Units','pixels',...
      'Position',[left(4) bottom(5) w(4) h],...
      'String','Drag It',...
      'Callback','mmstext DRAGTEXT');
   H.Color=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(4) bottom(6) w(4) h],...
      'String','Red|Green|Blue|Cyan|Magenta|Yellow|Black|White|RGB->',...
      'Value',local_color(Tp(n).Color));
   H.FontSize=uicontrol('Parent',Hfgui,'Style','Popup',...
      'Units','pixels',...
      'Position',[left(4) bottom(7) w(4) h],...
      'String','8|9|10|12|14|16|18|24|Other->',...
      'Value',local_size(Tp(n).FontSize));
   
   uicontrol('Parent',Hfgui,'Style','PushButton',... % Done Pushbutton
      'Units','pixels',...
      'Position',[lb(5) bottom(1) wb h],...
      'String','Done',...
      'Callback','mmstext DONE');
   H.EditRotation=uicontrol('Parent',Hfgui,'Style','Edit',...
      'Units','pixels',...
      'Position',[left(5) bottom(4) w(5) h],...
      'String',sprintf('%.2f',Tp(n).Rotation));
   H.EditPosition=uicontrol('Parent',Hfgui,'Style','Edit',...
      'Units','pixels',...
      'Position',[left(5) bottom(5) w(5) h],...
      'String',sprintf('[%.3f  %.3f]',Tp(n).Position(1:2)));
   H.EditColor=uicontrol('Parent',Hfgui,'Style','Edit',...
      'Units','pixels',...
      'Position',[left(5) bottom(6) w(5) h],...
      'String',sprintf('[%.2f %.2f %.2f]',Tp(n).Color));
   H.EditFontSize=uicontrol('Parent',Hfgui,'Style','Edit',...
      'Units','pixels',...
      'Position',[left(5) bottom(7) w(5) h],...
      'String',sprintf('%.1f',Tp(n).FontSize));
   
   set(Hfgui,'Userdata',{Ht(:),Tp(:),n,Tp(:),H},'Visible','on')
   mmputptr(Hfgui)
   drawnow
   
elseif ischar(arg) % callbacks
   Hfgui=findobj('Type','figure','Tag','MMSTEXT');
   [Ht,Tp,n,Tpdef,H]=mmdeal(get(Hfgui,'Userdata'));
   switch arg
   case 'DONE'
      set(H.Axes,'Units','normalized')
      delete(Hfgui)
   case 'DELETE'
      if strcmp(get(Ht(n),'HandleVisibility'),'on')
         nnew=max(n-1,1);
         delete(Ht(n))
         Ht(n)=[]; Tp(n)=[]; Tpdef(n)=[];
         n=nnew;
         set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
         mmstext UPDATEGUI
      else
         warndlg('Can''t Delete This Text Object!')
      end
      
   case 'NEW'
      Htn=text('Parent',H.Axes,...
         'String','MMSTEXT',...
         'Units','normalized',...
         'Position',[.5 .5 0],...
         'HorizontalAlignment','center');
      Ht=[Htn; Ht];
      Tp=[mmgetset(Htn);Tp];
      Tpdef=[Tp(1);Tpdef];
      n=1;
      set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
      mmstext UPDATEGUI
      
   case 'REVERT'
      Tp(n)=Tpdef(n);
      set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
      mmstext UPDATEGUI
      
   case 'SELECT'
      n=get(H.SelectText,'Value');
      set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
      mmstext UPDATEGUI
      
   case 'APPLY'
      str=popupstr(H.Visible); % visible
      Tp(n).Visible=str;
      
      str=popupstr(H.Clipping); % clipping
      Tp(n).Clipping=str;
      
      str=popupstr(H.Interpreter); % interpreter
      Tp(n).Interpreter=str;
      
      str=popupstr(H.FontWeight); % font weight
      Tp(n).FontWeight=str;
      
      str=popupstr(H.FontAngle); % font angle
      Tp(n).FontAngle=str;
      
      str=get(H.EditString,'string'); % string edit box
      cstr=get(H.SelectText,'string');
      cstr{n}=str;
      set(H.SelectText,'String',cstr)
      Tp(n).String=str;
      
      str=popupstr(H.VerticalAlignment); % vertical alignment
      Tp(n).VerticalAlignment=str;
      
      str=popupstr(H.HorizontalAlignment); % horizontal alignment
      Tp(n).HorizontalAlignment=str;
      
      str=popupstr(H.Rotation); % rotation
      if strcmp(str,'Other->') % Other rotation, get editbox string
         str=get(H.EditRotation,'String');
         val=str2num(str);
         if isempty(val) % can't figure it out, restore original
            set(H.EditRotation,'String',sprintf('%.1f',Tp(n).Rotation))
            val=Tp(n).Rotation;
         end
      else % standard rotation
         val=str2num(str);
         set(H.EditRotation,'string',str)
      end
      Tp(n).Rotation=val;
      
      str=popupstr(H.Color); % color
      if strcmp(str,'RGB->') % custom color
         str=get(H.EditColor,'String');
         val=str2num(str);
         if isempty(val)
            val=Tp(n).Color;
         end
         val=mmrgb(val,Tp(n).Color);
      else % standard color
         val=mmrgb(str);
         set(H.EditColor,'String',sprintf('[%.2f %.2f %.2f]',val))
      end
      Tp(n).Color=val;
      
      str=get(H.EditPosition,'String'); % position edit box
      val=str2num(str);
      if isempty(val)
         val=Tp(n).Position;
      end
      val=mmlimit(val,-.2,1.2);
      Tp(n).Position=val;
      set(H.EditPosition,'string',sprintf('[%.3f  %.3f]',val(1:2)))
      
      str=popupstr(H.FontSize);
      if strcmp(str,'Other->') % custom size
         str=get(H.EditFontSize,'String');
         val=str2num(str);
         if isempty(val)
            val=Tp(n).FontSize;
         end
      else % standard size
         val=str2num(str);
         set(H.EditFontSize,'String',sprintf('%.1f',val))
      end
      Tp(n).FontSize=val;
      
      set(Ht(n),Tp(n)) % update selected string using structures
      
      set(H.Fig,'WindowButtonDownFcn','',...
         'WindowButtonMotionFcn','',...
         'WindowButtonUpFcn','')
      
      set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
      
   case 'UISETFONT'
      val=uisetfont(Ht(n),'Choose Font Name');
      if isstruct(val)
         Tp(n).FontName=val.FontName;
         Tp(n).FontSize=val.FontSize;
         Tp(n).FontWeight=val.FontWeight;
         Tp(n).FontAngle=val.FontAngle;
         set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
         mmstext UPDATEGUI
      end
      
   case 'DRAGTEXT'
      set(H.Fig,'WindowButtonDownFcn','mmstext BUTTONDOWN')
      figure(H.Fig)
      set(Ht(n),'EraseMode','xor',...
         'SelectionHighlight','on','Selected','on',...
         'Visible','on')
      mmputptr(Ht(n))
      
   case 'BUTTONDOWN'
      set(H.Fig,'WindowButtonMotionFcn','mmstext MOTION',...
         'WindowButtonUpFcn','mmstext BUTTONUP')
      
   case 'MOTION'
      val=get(H.Fig,'CurrentPoint');
      apos=get(H.Axes,'Position');
      val=(val-apos(1:2))./apos(3:4);
      set(Ht(n),'Position',val)
      
   case 'BUTTONUP'
      val=get(Ht(n),'Position');
      Tp(n).Position=val;
      set(H.EditPosition,'String',sprintf('[%.3f  %.3f]',val(1:2)))
      set(Hfgui,'Userdata',{Ht,Tp,n,Tpdef,H})
      figure(Hfgui)
      mmputptr(Hfgui)
      mmstext UPDATEGUI
      
   case 'UPDATEGUI'
      set(Ht(n),'Erasemode','normal','Selected','off')
      set(H.Fig,'WindowButtonDownFcn','',...
         'WindowButtonMotionFcn','',...
         'WindowButtonUpFcn','')
      
      set(H.Visible,'Value',2-mmonoff(Tp(n).Visible))
      set(H.Clipping,'Value',2-mmonoff(Tp(n).Clipping))
      set(H.Interpreter,'Value',1+strcmp(Tp(n).Interpreter,'none'))
      set(H.FontWeight,'Value',local_weight(Tp(n).FontWeight))
      set(H.FontAngle,'Value',local_angle(Tp(n).FontAngle))
      set(H.FontName,'String',Tp(n).FontName)
      set(H.SelectText,'String',{Tp.String},'Value',n)
      
      
      set(H.VerticalAlignment,'Value',local_valign(Tp(n).VerticalAlignment))
      set(H.HorizontalAlignment,'Value',local_halign(Tp(n).HorizontalAlignment))
      set(H.Rotation,'Value',local_rotate(Tp(n).Rotation))
      set(H.EditRotation,'String',sprintf('%.1f',Tp(n).Rotation))
      set(H.DragText,'Value',1)
      set(H.EditPosition,'String',sprintf('[%.3f  %.3f]',Tp(n).Position(1:2)))
      
      set(H.Color,'Value',local_color(Tp(n).Color))
      set(H.EditColor,'String',sprintf('[%.2f %.2f %.2f]',Tp(n).Color))
      set(H.FontSize,'Value',local_size(Tp(n).FontSize));
      set(H.EditFontSize,'String',sprintf('%.1f',Tp(n).FontSize))
      
      set(H.EditString,'string',Tp(n).String)
   end
end
%-------------------------------------
function v=local_color(arg)
rgb=[1 0 0;0 1 0;0 0 1;0 1 1;1 0 1;1 1 0;0 0 0;1 1 1];
v=mmfind(arg,rgb);
if isempty(v)
   v=9;
end
%-------------------------------------
function v=local_weight(arg)
s=char('light','normal','demi','bold');
v=strmatch(lower(arg),s);
%-------------------------------------
function v=local_angle(arg)
s=char('normal','italic','oblique');
v=strmatch(lower(arg),s);
%-------------------------------------
function v=local_halign(arg)
s=char('left','center','right');
v=strmatch(lower(arg),s);
%-------------------------------------
function v=local_valign(arg)
s=char('top','cap','middle','baseline','bottom');
v=strmatch(lower(arg),s);
%-------------------------------------
function v=local_rotate(arg)
switch mod(arg+180,360)-180;
case 0
   v=1;
case 90
   v=2;
case {-180 180}
   v=3;
case {270 -90}
   v=4;
otherwise
   v=5;
end
%-------------------------------------
function v=local_size(arg)
n=[8 9 10 12 14 16 18 24];
v=find(arg==n);
if isempty(v)
   v=length(n)+1;
end
