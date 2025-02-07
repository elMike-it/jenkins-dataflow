import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import os
os.environ['USER'] = 'jenkins'

class TransformToUpperCase(beam.DoFn):
    def process(self, element):
        yield element.upper()

def run():
    pipeline_options = PipelineOptions(
        runner='DataflowRunner',
        project='test-interno-trendit',  # Reemplaza con tu ID de proyecto
        region='us-central1',          # Reemplaza con tu región preferida
        temp_location='gs://jenkins-dataflow/temp',  # Reemplaza con tu bucket GCS
        template_location='gs://jenkins-dataflow/templates/template.json',  # Ubicación para el template

    )

    with beam.Pipeline(options=pipeline_options) as pipeline:
        (
            pipeline
            | 'Read Input File' >> beam.io.ReadFromText('gs://jenkins-dataflow/input/input.txt')
            | 'Transform to Uppercase' >> beam.ParDo(TransformToUpperCase())
            | 'Write Output File' >> beam.io.WriteToText('gs://jenkins-dataflow/output/output')
        )

if __name__ == '__main__':
    run()
