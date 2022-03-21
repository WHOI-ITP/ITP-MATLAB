function filter_obj = pre_filter_factory(filt, args)

classes = containers.Map;
classes('system') = @SystemFilter;
classes('latitude') = @LatitudeFilter;
classes('longitude') = @LongitudeFilter;
classes('date_time') = @DateTimeFilter;
classes('direction') = @DirectionFilter;
classes('month') = @MonthFilter;
classes('extra_variables') = @ExtraVariableFilter;

if ~classes.isKey(filt)
    error('Unknown filter "%s"', filt)
end

filter_class = classes(filt);
filter_obj = filter_class(args);
