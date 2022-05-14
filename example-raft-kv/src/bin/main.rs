use clap::Parser;
use env_logger::Env;
use example_raft_key_value::network::raft_network_impl::ExampleNetwork;
use example_raft_key_value::start_example_raft_node;
use example_raft_key_value::store::ExampleStore;
use example_raft_key_value::ExampleTypeConfig;
use openraft::Raft;

use tracing::Instrument;
use tracing_subscriber::prelude::*;

use coruscant_subscriber::dependency::DependencyLayer;

pub type ExampleRaft = Raft<ExampleTypeConfig, ExampleNetwork, ExampleStore>;

#[derive(Parser, Clone, Debug)]
#[clap(author, version, about, long_about = None)]
pub struct Opt {
    #[clap(long)]
    pub id: u64,

    #[clap(long)]
    pub http_addr: String,

    #[clap(long, default_value = "localhost:6831")]
    jaeger_agent: String,
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Setup the logger
    env_logger::init_from_env(Env::default().default_filter_or("info"));

    // Parse the parameters passed by arguments.
    let options = Opt::parse();

    // opentelemetry
    // let tracer = opentelemetry_jaeger::new_pipeline()
    //     .with_agent_endpoint(options.jaeger_agent)
    //     .with_service_name("raft_node")
    //     // .install_simple()
    //     .install_batch(opentelemetry::runtime::Tokio)
    //     .expect("Failed to init jaeger tracer");
    // let opentelemetry = tracing_opentelemetry::layer().with_tracer(tracer);
    let (dep_layer, dep_processor) = DependencyLayer::construct();
    // tracing_subscriber::registry()
    //     .with(opentelemetry)
    //     .try_init()
    //     .expect("Failed to init opentelemetry subscriber");
    let subscriber = tracing_subscriber::Registry::default()
      .with(dep_layer)
      // .with(opentelemetry)
    ;
    tracing::subscriber::set_global_default(subscriber)
        .expect("setting global default failed");

    // write dependency periodically
    dep_processor.install_periodic_write_threaded();

    // start node
    start_example_raft_node(options.id, options.http_addr)
      .instrument(tracing::info_span!("start_example_raft_node"))
      .await
}
