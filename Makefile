
# prep ref ASTER

#$(WORKDIR)/aster.vnir3n.$(EPSG).tif: $(WORKDIR)/data1.l3a.vnir3n.tif
$(WORKDIR)/aster.vnir3n.$(EPSG).tif: $(WORKDIR)/data1.l3a.vnir3n.tif
	rm -f $@ && mkdir -p `dirname $@`
	gdalwarp -t_srs EPSG:$(EPSG) -tr 5 5 $(WARPOPTS) $< $@
#$(WORKDIR)/aster.vnir2.$(EPSG).tif: $(WORKDIR)/data1.l3a.vnir2.tif
$(WORKDIR)/aster.vnir2.$(EPSG).tif: $(WORKDIR)/data1.l3a.vnir2.tif
	rm -f $@ && mkdir -p `dirname $@`
	gdalwarp -t_srs EPSG:$(EPSG) -tr 5 5 $(WARPOPTS) $< $@

#correcting NIR

$(WORKDIR)/hodo.b4.tif: $(INIMG)
	rm -f $@ && mkdir -p `dirname $@`
	gdal_translate -b 4 -co compress=deflate $< $@

$(WORKDIR)/hodo.b4__shifted_to__aster.vnir3n.$(EPSG).bsq: $(WORKDIR)/aster.vnir3n.$(EPSG).tif $(WORKDIR)/hodo.b4.tif
	rm -f $@ && mkdir -p `dirname $@`
	python3 $(HOME)/anaconda3/envs/arosics/bin/arosics_cli.py local -max_iter 100 -max_shift 10000 -ws 8192 8192 -nodata 0 0 $+ $(nSample)

#correcting visible
$(WORKDIR)/hodo.b123.tif: $(INIMG)
	rm -f $@ && mkdir -p `dirname $@`
	gdal_translate -b 1 -b 2 -b 3 -co compress=deflate $< $@

#/dev/shm//hodo.b123__shifted_to__aster.vnir2.32648.bsq: $(WORKDIR)/aster.vnir2.$(EPSG).tif $(WORKDIR)/hodo.b123.tif

$(WORKDIR)/hodo.b123__shifted_to__aster.vnir2.$(EPSG).bsq: $(WORKDIR)/aster.vnir2.$(EPSG).tif $(WORKDIR)/hodo.b123.tif
	rm -f $@ && mkdir -p `dirname $@`
	python3 $(HOME)/anaconda3/envs/arosics/bin/arosics_cli.py local -br 1 -bs 3 -max_iter 100 -max_shift 10000 -ws 8192 8192 -nodata 0 0 $+ $(nSample)

$(OUTPUT): $(WORKDIR)/hodo.b123__shifted_to__aster.vnir2.$(EPSG).bsq $(WORKDIR)/hodo.b4__shifted_to__aster.vnir3n.$(EPSG).bsq
	rm -f $@ && mkdir -p `dirname $@`
	gdal_merge.py -o $@ -separate -co compress=deflate $+

# ASTER acquisition
../AST_L3A/$(ASTID).tar.bz2:
	rm -f $@ && mkdir -p `dirname $@`
	wget -O $@ http://aster.geogrid.org/ASTER/fetchL3A/`basename $@`
$(WORKDIR)/data1.l3a.vnir2.tif: ../AST_L3A/$(ASTID).tar.bz2
	rm -f $@ && mkdir -p `dirname $@`
	tar xa --strip=1 -C $(WORKDIR) -f $< `tar taf $< | grep data1.l3a.vnir2.tif`

$(WORKDIR)/data1.l3a.vnir3n.tif: ../AST_L3A/$(ASTID).tar.bz2
	rm -f $@ && mkdir -p `dirname $@`
	tar xa --strip=1 -C $(WORKDIR) -f $< `tar taf $< | grep data1.l3a.vnir3n.tif`


