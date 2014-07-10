require "manual_change_note_database_exporter"

class ObserversRegistry

  def initialize(dependencies)
    @cma_case_content_api_exporter = dependencies.fetch(:cma_case_content_api_exporter)
    @aaib_report_content_api_exporter = dependencies.fetch(:aaib_report_content_api_exporter)
    @finder_api_notifier = dependencies.fetch(:finder_api_notifier)
    @cma_case_panopticon_registerer = dependencies.fetch(:cma_case_panopticon_registerer)
    @aaib_report_panopticon_registerer = dependencies.fetch(:aaib_report_panopticon_registerer)
    @manual_panopticon_registerer = dependencies.fetch(:manual_panopticon_registerer)
    @manual_document_panopticon_registerer = dependencies.fetch(:manual_document_panopticon_registerer)
    @manual_content_api_exporter = dependencies.fetch(:manual_content_api_exporter)
    @cma_case_rummager_indexer = dependencies.fetch(:cma_case_rummager_indexer)
    @aaib_report_rummager_indexer = dependencies.fetch(:aaib_report_rummager_indexer)
    @specialist_document_content_api_withdrawer = dependencies.fetch(:specialist_document_content_api_withdrawer)
    @finder_api_withdrawer = dependencies.fetch(:finder_api_withdrawer)
    @cma_case_rummager_deleter = dependencies.fetch(:cma_case_rummager_deleter)
    @aaib_report_rummager_deleter = dependencies.fetch(:aaib_report_rummager_deleter)
  end

  def cma_case_publication
    [
      cma_case_content_api_exporter,
      finder_api_notifier,
      cma_case_panopticon_registerer,
      cma_case_rummager_indexer,
    ]
  end

  def aaib_report_publication
    [
      aaib_report_content_api_exporter,
      finder_api_notifier,
      aaib_report_panopticon_registerer,
      aaib_report_rummager_indexer,
    ]
  end

  def cma_case_update
    [
      cma_case_panopticon_registerer,
    ]
  end

  def manual_publication
    [
      publication_logger,
      manual_panopticon_registerer,
      manual_content_api_exporter,
      manual_change_note_content_api_exporter,
    ]
  end

  def manual_creation
    [
      manual_panopticon_registerer,
    ]
  end

  def manual_document_creation
    [
      manual_document_panopticon_registerer,
    ]
  end

  def cma_case_creation
    [
      cma_case_panopticon_registerer,
    ]
  end

  def aaib_report_creation
    [
      aaib_report_panopticon_registerer,
    ]
  end

  def cma_case_withdrawal
    [
      specialist_document_content_api_withdrawer,
      finder_api_withdrawer,
      cma_case_panopticon_registerer,
      cma_case_rummager_deleter,
    ]
  end

  def aaib_report_withdrawal
    [
      specialist_document_content_api_withdrawer,
      finder_api_withdrawer,
      aaib_report_panopticon_registerer,
      aaib_report_rummager_deleter,
    ]
  end

  private

  attr_reader(
    :cma_case_content_api_exporter,
    :aaib_report_content_api_exporter,
    :finder_api_notifier,
    :cma_case_panopticon_registerer,
    :aaib_report_panopticon_registerer,
    :manual_panopticon_registerer,
    :manual_document_panopticon_registerer,
    :manual_content_api_exporter,
    :cma_case_rummager_indexer,
    :aaib_report_rummager_indexer,
    :specialist_document_content_api_withdrawer,
    :finder_api_withdrawer,
    :cma_case_rummager_deleter,
    :aaib_report_rummager_deleter,
  )

  def manual_change_note_content_api_exporter
    ->(manual) {
      ManualChangeNoteDatabaseExporter.new(
        export_target: ManualChangeHistory,
        publication_logs: PublicationLog,
        manual: manual,
      ).call
    }
  end

  def publication_logger
    ->(manual) {
      manual.documents.each do |doc|
        PublicationLog.create!(
          title: doc.title,
          slug: doc.slug,
          change_note: doc.change_note,
        )
      end
    }
  end
end
