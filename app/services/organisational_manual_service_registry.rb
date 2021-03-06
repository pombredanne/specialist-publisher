class OrganisationalManualServiceRegistry
  def initialize(dependencies)
    @organisation_slug = dependencies.fetch(:organisation_slug)
  end

  def list(context)
    ListManualsService.new(
      manual_repository: manual_repository,
      context: context,
    )
  end

  def new(context)
    ->() { manual_builder.call(title: "") }
  end

  def create(attributes)
    CreateManualService.new(
      manual_repository: manual_repository,
      manual_builder: manual_builder,
      listeners: observers.creation,
      attributes: attributes,
    )
  end

  def update(manual_id, attributes)
    UpdateManualService.new(
      manual_repository: manual_repository,
      manual_id: manual_id,
      attributes: attributes,
    )
  end

  def show(manual_id)
    ShowManualService.new(
      manual_repository: manual_repository,
      manual_id: manual_id,
    )
  end

  def queue_publish(manual_id)
    QueuePublishManualService.new(
      PublishManualWorker,
      manual_repository,
      manual_id,
    )
  end

  def preview(manual_id, attributes)
    PreviewManualService.new(
      repository: manual_repository,
      builder: manual_builder,
      renderer: manual_renderer,
      manual_id: manual_id,
      attributes: attributes,
    )
  end

private
  attr_reader :organisation_slug

  def manual_renderer
    SpecialistPublisherWiring.get(:manual_renderer)
  end

  def manual_builder
    # TODO Use ManualBuilder.new instead
    SpecialistPublisherWiring.get(:manual_builder)
  end

  def manual_repository
    # TODO Get this from a RepositoryRegistry
    SpecialistPublisherWiring
      .get(:organisational_manual_repository_factory)
      .call(organisation_slug)
  end

  def observers
    @observers ||= ManualObserversRegistry.new
  end

end
