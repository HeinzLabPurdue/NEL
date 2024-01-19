classdef noiseBandMaskerDesigner2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        GridLayout      matlab.ui.container.GridLayout
        GridLayout2     matlab.ui.container.GridLayout
        GridLayout3     matlab.ui.container.GridLayout
        nbandsLabel     matlab.ui.control.Label
        nbandsSpinner   matlab.ui.control.Spinner
        TabGroup2       matlab.ui.container.TabGroup
        Band1Tab        matlab.ui.container.Tab
        GridLayout8     matlab.ui.container.GridLayout
        GridLayout9     matlab.ui.container.GridLayout
        Slider          matlab.ui.control.Slider
        GridLayout4     matlab.ui.container.GridLayout
        GridLayout5     matlab.ui.container.GridLayout
        UIAxes          matlab.ui.control.UIAxes
        GridLayout6     matlab.ui.container.GridLayout
        GridLayout7     matlab.ui.container.GridLayout
        GenerateButton  matlab.ui.control.StateButton
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 678 616];
            app.UIFigure.Name = 'UI Figure';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {150, '1x', 50};
            app.GridLayout.Padding = [2 2 2 2];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {35, '1x'};
            app.GridLayout2.Padding = [2 2 2 2];
            app.GridLayout2.Layout.Row = 2;
            app.GridLayout2.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout2);
            app.GridLayout3.ColumnWidth = {60, 50, '1x'};
            app.GridLayout3.RowHeight = {20};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;

            % Create nbandsLabel
            app.nbandsLabel = uilabel(app.GridLayout3);
            app.nbandsLabel.HorizontalAlignment = 'right';
            app.nbandsLabel.Layout.Row = 1;
            app.nbandsLabel.Layout.Column = 1;
            app.nbandsLabel.Text = 'n-bands';

            % Create nbandsSpinner
            app.nbandsSpinner = uispinner(app.GridLayout3);
            app.nbandsSpinner.Layout.Row = 1;
            app.nbandsSpinner.Layout.Column = 2;

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.GridLayout2);
            app.TabGroup2.Layout.Row = 2;
            app.TabGroup2.Layout.Column = 1;

            % Create Band1Tab
            app.Band1Tab = uitab(app.TabGroup2);
            app.Band1Tab.Title = 'Band 1';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.Band1Tab);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout8.Padding = [2 2 2 2];

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout8);
            app.GridLayout9.ColumnWidth = {'1x'};
            app.GridLayout9.Padding = [2 2 2 2];
            app.GridLayout9.Layout.Row = 1;
            app.GridLayout9.Layout.Column = 1;

            % Create Slider
            app.Slider = uislider(app.GridLayout9);
            app.Slider.Layout.Row = 1;
            app.Slider.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'1x', 600, '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Padding = [2 2 2 2];
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 1;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout4);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout5);
            title(app.UIAxes, 'Frequency view')
            xlabel(app.UIAxes, 'f (kHz)')
            ylabel(app.UIAxes, 'Amp (dB)')
            app.UIAxes.XLim = [0 12];
            app.UIAxes.YLim = [-60 10];
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Padding = [2 2 2 2];
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout6);
            app.GridLayout7.ColumnWidth = {'1x'};
            app.GridLayout7.RowHeight = {'1x'};
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 2;

            % Create GenerateButton
            app.GenerateButton = uibutton(app.GridLayout7, 'state');
            app.GenerateButton.Text = 'Generate';
            app.GenerateButton.Layout.Row = 1;
            app.GenerateButton.Layout.Column = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = noiseBandMaskerDesigner2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end